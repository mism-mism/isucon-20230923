.PHONY: gogo build stop-services start-services truncate-logs bench kataribe

gogo: stop-services build deploy truncate-logs start-services bench

build:
	cd go && make build

deploy:
	scp go/app isucon-s2:webapp/go/app
	scp go/app isucon-s3:webapp/go/app

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop cco.golang.service 
	ssh isucon-s2 "sudo systemctl stop cco.golang.service"
	ssh isucon-s3 "sudo systemctl stop cco.golang.service"
	sudo systemctl stop cco.golang.service
	ssh isucon-db "sudo systemctl stop mysql"

start-services:
	ssh isucon-db "sudo systemctl start mysql"
	ssh isucon-s3 "sudo systemctl start cco.golang.service"
	ssh isucon-s2 "sudo systemctl start cco.golang.service"
	sudo systemctl start cco.golang.service
	sudo systemctl start nginx
	sleep 10

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log
	ssh isucon-db "sudo truncate --size 0 /var/log/mysql/mysql-slow.log"

kataribe:
	sudo cat /var/log/nginx/access.log | ./../kataribe -conf ~/kataribe.toml

bench:
	ssh isucon-bench 'cd ~/bench && ./bench -remotes "172.31.8.31"'
