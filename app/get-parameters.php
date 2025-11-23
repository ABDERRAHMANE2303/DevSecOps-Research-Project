<?php
// Simplified DB configuration: use provided secret ARN and RDS endpoint.
error_log('Resolving DB credentials');

if (file_exists('aws-autoloader.php')) {
  require 'aws-autoloader.php';
}

$region = getenv('AWS_REGION') ?: getenv('AWS_DEFAULT_REGION') ?: 'us-east-1';
$secretArn = getenv('DB_SECRET_ARN') ?: 'arn:aws:secretsmanager:us-east-1:637952570965:secret:devsecopsproject-db-credentials-20251122234228147000000001-en9xBE';

try {
  if (!class_exists('Aws\SecretsManager\SecretsManagerClient') || !class_exists('Aws\Rds\RdsClient')) {
    throw new Exception('AWS SDK not loaded');
  }
  $secrets_client = new Aws\SecretsManager\SecretsManagerClient([
    'version' => 'latest',
    'region'  => $region
  ]);
  $rds_client = new Aws\Rds\RdsClient([
    'version' => 'latest',
    'region'  => $region
  ]);

  // Describe DB instances (first one assumed target)
  $instances = $rds_client->describeDBInstances();
  $ep = $instances['DBInstances'][0]['Endpoint']['Address'];

  $secretValue = $secrets_client->getSecretValue(['SecretId' => $secretArn]);
  $payload = json_decode($secretValue['SecretString'], true);
  $un = $payload['username'] ?? 'admin';
  $pw = $payload['password'] ?? '';
  $db = $payload['dbname'] ?? 'mydb';
} catch (Exception $e) {
  // Fallback to environment/local defaults
  $ep = getenv('DB_HOST') ?: 'localhost';
  $db = getenv('DB_NAME') ?: 'mydb';
  $un = getenv('DB_USER') ?: 'webapp_user';
  $pw = getenv('DB_PASSWORD') ?: 'your_password';
}

error_log('DB settings: endpoint=' . $ep . ' db=' . $db . ' user=' . $un);
?>
