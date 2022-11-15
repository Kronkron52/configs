Вопросы к интервью



1) Какие коды сообщений или ошибок HTTP ты знаешь и что это значит ?
1xx informational code  : 100 - continue, 101 - Switching protocol
2xx successful codes    : 200 - OK, 202 acccepted
3xx redirection code    : 301 - moved permanently, 302 -found
4xx client error codes  : 400 -bad request, 403 forbiddeb, 404 -page not found
5xx server error coed   : 500 -internal server error, 503 - servce unavailable


2) Какие DNS records ты знаешь, и что они означают ?
 A, CNAME, TXT, NS, SRV, MX, SOA, AAAA

3) Какие протоклы ты знаешь, номер порта этого протокола ?
 http 80     ftp 21
 https 443   sftp 22
 ssh 22
 dns 53

4) Какая разница между TCP и UDP протоколом, когда используется UDP ?
 tcp требует потверждения, что пакет дошёл, а UDP не требует

5) OSI model layers - какие ты знаешь ?
 1физический
 2канальный
 3сетевой
 4транспортный
 5сеансный
 6представления
 7прикладной

6) модель tcp/ip какие уровни ты знаешь ?
 1физический
 2сетевой ip icmp
 3транспортный tcp udp
 4прикладной http https ftp dns ssh

7) Какая subnet mask этого cidr 10.20.0.0/23 ?
 255.255.254.0

8) Как работает DNS, вводишь URL в Browser нажимаешь enter, что происходит?

9) Какой командой показать все работающие процессы на Linux ?
 ps aux, top, htop

10) Какой командой на Redhat linux сделать чтобы сервисы стартовали автоматом
 chkconfig on

11) Что внутри директории Linux: /proc
 Текущие процессы и их PID по дерикториям

12) Как увидеть connections, на каких портах LISTENING ?
 netstat
 lsof
 ss

13) Самая опасная команда Linux ?
 sudo rm -rf /

14) Какие оркестрации ты знаешь для Microservice и какими пользовался?
 k&s
 HashiCorp Nomad
 AWS Elastic Container Service
 AWS Fargate

15) Какие характерестики Микросервисов ты знаешь ?
 Маленький компонент а не монолит, всё разбито на разные мелкие компоненты
 компонент вебсервера
 компонент базы и тд
  Failure resistant несколько компонентво (взаимозаменяемых)
  decentralized
  stateless информация не должна сохранятся в контейнере

16) Тебе нужно соответствовать RPO 2 часа, как часто надо делать Backup ?
 каждые 2 часа

17) Какие Enterprise Firewall ты знаешь, названия ?
 cisco, Fortigate, Palo Alto AWS firewall WAF

18) Как ты делаешь troubleshoot slowness Вэб Сайта ?
 CPU на веб сервере, load balancer, RAM and CPU on DATAbase

19) Как проверить лимит sql DATAbase?
  load test witch average sql query
  средний запрос в базу

20) Как убрать нагрузку с Database Server ?
 Read Replica
 все запросы на чтение в репрлику, все запросы апдейт и изменение на мастер
 ElastiCache
 CDN-cloudfront  кэш запросов БД

21) Доступ из дома к серверу в Private subnet в data center, как это сделать?
 vpn, bastion host / jump box

22) Какие решения для CI/CD ты знаешь, какими ты пользовался ?
 Jenkins, Github Action, Gitlab CI/CD, BItbucket

23) Какие решения для GitOPS в k&s ты знаешь, какими ты пользовался?
  argoCD, FluxCD, JenkinsX

24) Как автоматически деплоить Helm Chart?
  K&s add-on helm operator + argoCD/FluxCD, Github Action

25) Какие минусы stateful приложения?
 вся инфа хранится на сервере в случае поломки, инфорамция может быть потеряна

26) Какие iaac решения ты использовал?
 ansible
 terraform


Базы данных
1) настраивал кластера, стендолоне базу данных по документации заказчика
2) расширения (плагины в мускуле) в пг не ставил
3) умею делать селекты в базу данных основываясь на документации вендора
4) архитектурой не занимался
5) использовал плагины питона при работе с ансиблой?
6) мониторинг ELK, строил графики в кибане
7) строил джобы
8) дженкинс умеет работать с ансиблой
9) помогал в контроле шаблонов при разворачивании
10) 
11)
