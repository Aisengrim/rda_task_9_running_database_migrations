#!/bin/bash
set -e

echo "INFO: Starting a MySQL database server for tests"

# cleanup (щоб можна було запускати багато разів)
docker rm -f mysql 2>/dev/null || true
docker network create test-network 2>/dev/null || true

docker run --name mysql --network=test-network --hostname mysql \
-e MYSQL_ROOT_PASSWORD=P@ssw0rd \
-v "$(pwd)":/scripts \
-d mysql:8.0-debian

echo "INFO: Waiting for database server to initialize"

until docker exec mysql mysqladmin ping -h "localhost" -u root -pP@ssw0rd --silent; do
  echo "Waiting for MySQL..."
  sleep 2
done

echo "INFO: Creating a database for test"
docker exec mysql sh -c 'mysql -u root -pP@ssw0rd < /scripts/test-queries/1-create-database.sql'

# --- helpers ---
run_liquibase() {
  docker run --rm --network=test-network \
  -v "$(pwd)":/repos --workdir /repos/ \
  -e INSTALL_MYSQL=true \
  -e LIQUIBASE_COMMAND_USERNAME=root \
  -e LIQUIBASE_COMMAND_PASSWORD=P@ssw0rd \
  -e LIQUIBASE_COMMAND_URL=jdbc:mysql://mysql:3306/ShopDB \
  liquibase/liquibase "$@"
}

run_test() {
  file=$1
  echo "INFO: Running test $file"
  docker exec mysql sh -c "mysql -u root -pP@ssw0rd < /scripts/test-queries/$file" > log.txt
  errors=$(grep "^Error" log.txt || true)
  if [ -n "$errors" ]; then
    echo "$errors"
    exit 1
  fi
}

# --- v0.0.1 ---
echo "INFO: Running migration 0.0.1"
run_liquibase update --labels="0.0.1"

echo "INFO: Tagging 0.0.1"
run_liquibase tag 0.0.1

run_test "2-test-0.0.1.sql"

# --- v0.0.2 ---
echo "INFO: Running migration 0.0.2"
run_liquibase update --labels="0.0.2"

echo "INFO: Tagging 0.0.2"
run_liquibase tag 0.0.2

run_test "3-test-0.0.2.sql"

# --- v0.0.3 ---
echo "INFO: Running migration 0.0.3"
run_liquibase update --labels="0.0.3"

echo "INFO: Tagging 0.0.3"
run_liquibase tag 0.0.3

run_test "3-test-0.0.3.sql"

# --- rollback to v0.0.2 ---
echo "INFO: rollback to 0.0.2"
run_liquibase rollback 0.0.2

run_test "3-test-0.0.2.sql"

# --- rollback to v0.0.1 ---
echo "INFO: rollback to 0.0.1"
run_liquibase rollback 0.0.1

run_test "2-test-0.0.1.sql"

echo "INFO: All tests passed successfully ✅"