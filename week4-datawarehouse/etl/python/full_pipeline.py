"""
Full ETL Pipeline - Tam ETL Süreci
Orchestrates the complete ETL process: Extract -> Transform -> Load
"""

import sys
import time
from datetime import datetime
from typing import Optional
from config import config, logger
from extract import OLTPExtractor
from transform import DataTransformer
from load import ETLLoader


class ETLPipeline:
    """Complete ETL Pipeline orchestrator"""

    def __init__(self):
        self.config = config
        self.extractor = OLTPExtractor()
        self.transformer = DataTransformer()
        self.loader = ETLLoader()

        self.start_time = None
        self.end_time = None
        self.execution_stats = {}

    def _log_stage(self, stage: str, status: str = "START"):
        """Log pipeline stage"""
        logger.info("\n" + "=" * 60)
        logger.info(f"[{status}] {stage}")
        logger.info("=" * 60)

    def connect_all(self):
        """Connect to all data sources and targets"""
        self._log_stage("Connecting to all systems")

        try:
            # Connect to source (OLTP)
            self.extractor.connect()

            # Connect to targets (OLAP + Data Lake)
            self.loader.connect_all()

            logger.info("✓ All connections established")
            return True

        except Exception as e:
            logger.error(f"✗ Failed to establish connections: {e}")
            return False

    def disconnect_all(self):
        """Disconnect from all systems"""
        self._log_stage("Disconnecting from all systems")

        try:
            self.extractor.disconnect()
            self.loader.disconnect_all()
            logger.info("✓ All connections closed")
        except Exception as e:
            logger.error(f"Warning: Error during disconnect: {e}")

    def run_extract_phase(self):
        """Execute extract phase"""
        self._log_stage("EXTRACT Phase - Reading from OLTP")

        phase_start = time.time()

        try:
            extracted_data = self.extractor.extract_all()

            phase_duration = time.time() - phase_start
            self.execution_stats['extract'] = {
                'duration': phase_duration,
                'tables': len(extracted_data),
                'total_rows': sum(len(df) for df in extracted_data.values())
            }

            logger.info(f"\n✓ Extract phase completed in {phase_duration:.2f}s")
            return extracted_data

        except Exception as e:
            logger.error(f"✗ Extract phase failed: {e}")
            raise

    def run_transform_phase(self, extracted_data):
        """Execute transform phase"""
        self._log_stage("TRANSFORM Phase - Converting to Star Schema")

        phase_start = time.time()

        try:
            transformed_data = self.transformer.transform_all(extracted_data)

            # Validate transformations
            is_valid = self.transformer.validate_transformations(transformed_data)

            if not is_valid:
                logger.warning("⚠ Some transformation validations failed")

            phase_duration = time.time() - phase_start
            self.execution_stats['transform'] = {
                'duration': phase_duration,
                'tables': len(transformed_data),
                'total_rows': sum(len(df) for df in transformed_data.values()),
                'valid': is_valid
            }

            logger.info(f"\n✓ Transform phase completed in {phase_duration:.2f}s")
            return transformed_data

        except Exception as e:
            logger.error(f"✗ Transform phase failed: {e}")
            raise

    def run_load_phase(self, transformed_data):
        """Execute load phase"""
        self._log_stage("LOAD Phase - Writing to OLAP & Data Lake")

        phase_start = time.time()

        try:
            self.loader.load_all(transformed_data)

            phase_duration = time.time() - phase_start
            self.execution_stats['load'] = {
                'duration': phase_duration,
                'tables': len(transformed_data),
                'total_rows': sum(len(df) for df in transformed_data.values())
            }

            logger.info(f"\n✓ Load phase completed in {phase_duration:.2f}s")
            return True

        except Exception as e:
            logger.error(f"✗ Load phase failed: {e}")
            raise

    def run_once(self):
        """Execute one complete ETL cycle"""
        self.start_time = datetime.now()

        logger.info("\n" + "=" * 60)
        logger.info(f"ETL Pipeline Started: {self.start_time}")
        logger.info("=" * 60)

        try:
            # Connect to all systems
            if not self.connect_all():
                return False

            # Phase 1: Extract
            extracted_data = self.run_extract_phase()

            # Phase 2: Transform
            transformed_data = self.run_transform_phase(extracted_data)

            # Phase 3: Load
            self.run_load_phase(transformed_data)

            # Success
            self.end_time = datetime.now()
            self._print_execution_summary()

            return True

        except Exception as e:
            logger.error(f"\n✗ ETL Pipeline Failed: {e}")
            self.end_time = datetime.now()
            return False

        finally:
            self.disconnect_all()

    def run_continuous(self, interval_seconds: Optional[int] = None):
        """
        Run ETL continuously with specified interval

        Args:
            interval_seconds: Seconds between runs (uses config if None)
        """
        if interval_seconds is None:
            interval_seconds = self.config.interval_seconds

        logger.info("=" * 60)
        logger.info(f"Starting Continuous ETL Mode")
        logger.info(f"Interval: {interval_seconds} seconds ({interval_seconds / 60:.1f} minutes)")
        logger.info("Press Ctrl+C to stop")
        logger.info("=" * 60)

        cycle_count = 0

        while True:
            try:
                cycle_count += 1
                logger.info(f"\n{'*' * 60}")
                logger.info(f"ETL Cycle #{cycle_count}")
                logger.info(f"{'*' * 60}")

                success = self.run_once()

                if success:
                    logger.info(f"\n✓ Cycle #{cycle_count} completed successfully")
                else:
                    logger.error(f"\n✗ Cycle #{cycle_count} failed")

                logger.info(f"\nNext cycle in {interval_seconds} seconds...")
                logger.info(f"Next run: {datetime.now().replace(second=0, microsecond=0)}")

                time.sleep(interval_seconds)

            except KeyboardInterrupt:
                logger.info("\n\n" + "=" * 60)
                logger.info("ETL stopped by user")
                logger.info(f"Total cycles completed: {cycle_count}")
                logger.info("=" * 60)
                break

            except Exception as e:
                logger.error(f"\n✗ Error in cycle #{cycle_count}: {e}")
                logger.info(f"Retrying in {interval_seconds} seconds...")
                time.sleep(interval_seconds)

    def _print_execution_summary(self):
        """Print execution summary"""
        duration = (self.end_time - self.start_time).total_seconds()

        logger.info("\n" + "=" * 60)
        logger.info("ETL EXECUTION SUMMARY")
        logger.info("=" * 60)
        logger.info(f"Start Time:  {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        logger.info(f"End Time:    {self.end_time.strftime('%Y-%m-%d %H:%M:%S')}")
        logger.info(f"Duration:    {duration:.2f}s ({duration / 60:.2f} minutes)")
        logger.info("=" * 60)

        # Phase details
        for phase, stats in self.execution_stats.items():
            logger.info(f"\n{phase.upper()} Phase:")
            logger.info(f"  Duration:    {stats['duration']:.2f}s")
            logger.info(f"  Tables:      {stats['tables']}")
            logger.info(f"  Total Rows:  {stats['total_rows']:,}")
            if 'valid' in stats:
                logger.info(f"  Validation:  {'✓ Passed' if stats['valid'] else '✗ Failed'}")

        logger.info("\n" + "=" * 60)
        logger.info("✓ ETL Pipeline Completed Successfully")
        logger.info("=" * 60)


def main():
    """Main entry point"""
    logger.info("\n" + "=" * 60)
    logger.info("ETL SERVICE - Week 4 Data Warehouse")
    logger.info("=" * 60)

    # Show configuration
    logger.info(config)

    # Create pipeline
    pipeline = ETLPipeline()

    # Check run mode
    run_mode = config.run_mode

    try:
        if run_mode == 'once':
            logger.info("Running in ONCE mode - single execution\n")
            success = pipeline.run_once()
            sys.exit(0 if success else 1)

        elif run_mode == 'continuous':
            logger.info("Running in CONTINUOUS mode\n")
            pipeline.run_continuous()

        else:
            logger.error(f"Unknown run mode: {run_mode}")
            logger.info("Valid modes: 'once' or 'continuous'")
            sys.exit(1)

    except Exception as e:
        logger.error(f"Fatal error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()