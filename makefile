all: create_db

install:
	sudo apt-get install mysql-server mysql-client

start:
	# sudo service mysql status
	sudo service mysql start
	# sudo mysql
create_user: install start
	sudo mysql -u root -e "\
	CREATE USER 'maolin'@'%' IDENTIFIED WITH mysql_native_password BY '123456'; \
	GRANT ALL PRIVILEGES ON *.* TO 'maolin'@'%' WITH GRANT OPTION; \
	FLUSH PRIVILEGES; \
	"

USER = maolin
PASS = 123456

create_db: install start create_user
	sudo mysql -u maolin -p -t < employees.sql
	sudo mysql -u maolin -p -t < /workspace/test_db/sakila/sakila-mv-schema.sql
	sudo mysql -u maolin -p -t < /workspace/test_db/sakila/sakila-mv-data.sql

install_sql2dbml:
	sudo apt update
	sudo apt install npm
	sudo npm install -g @dbml/cli

export_to_sql: install start
	sudo mysqldump -u maolin -p --no-data employees > employees_db.sql
	sudo mysqldump -u maolin -p --no-data sakila > sakila_db.sql

export_to_dbml: install_sql2dbml start
	sql2dbml --mysql ./employees.sql -o employees.dbml
	sql2dbml --mysql ./sakila/sakila-mv-schema.sql -o sakila.dbml
