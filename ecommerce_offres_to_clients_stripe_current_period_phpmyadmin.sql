-- Cotton — période courante des Subscriptions Stripe
-- Migration additive et idempotente, sans backfill ni modification des lignes existantes.
-- Compatible avec les versions MySQL/MariaDB supportant PREPARE et information_schema.

SET @cotton_schema := DATABASE();

SET @cotton_add_period_start := (
  SELECT IF(
    COUNT(*) = 0,
    'ALTER TABLE `ecommerce_offres_to_clients` ADD COLUMN `stripe_current_period_start` DATETIME NULL DEFAULT NULL AFTER `asset_stripe_productId`',
    'SELECT ''stripe_current_period_start already exists'' AS migration_status'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @cotton_schema
    AND TABLE_NAME = 'ecommerce_offres_to_clients'
    AND COLUMN_NAME = 'stripe_current_period_start'
);
PREPARE cotton_period_start_stmt FROM @cotton_add_period_start;
EXECUTE cotton_period_start_stmt;
DEALLOCATE PREPARE cotton_period_start_stmt;

SET @cotton_add_period_end := (
  SELECT IF(
    COUNT(*) = 0,
    'ALTER TABLE `ecommerce_offres_to_clients` ADD COLUMN `stripe_current_period_end` DATETIME NULL DEFAULT NULL AFTER `stripe_current_period_start`',
    'SELECT ''stripe_current_period_end already exists'' AS migration_status'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @cotton_schema
    AND TABLE_NAME = 'ecommerce_offres_to_clients'
    AND COLUMN_NAME = 'stripe_current_period_end'
);
PREPARE cotton_period_end_stmt FROM @cotton_add_period_end;
EXECUTE cotton_period_end_stmt;
DEALLOCATE PREPARE cotton_period_end_stmt;

