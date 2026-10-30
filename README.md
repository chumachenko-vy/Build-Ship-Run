# Build-Ship-Run

Практичне завдання курсу DevOps: вебсервіс на Go, що віддає SVG-анімацію (бібліотека [Vivus](https://github.com/maxwellito/vivus)), упакований у контейнер і розгорнутий у Kubernetes.

**Demo:** https://bsr.vlch.net (стрілки ← / → перемикають кадри, пробіл — пауза)

## Структура

~~~
src/main.go    вебсервер на Go, віддає поточну теку
html/          index.html, vivus.min.js, кадри frame1..17.svg
Dockerfile     multi-stage збірка: golang:1.26 -> scratch
k8s/           Deployment, Service, Ingress з TLS
infra/         ClusterIssuer'и Let's Encrypt, middleware редиректу на HTTPS
~~~

## Локальний запуск

~~~bash
go build -o app ./src
cd html && ../app
~~~

Сервіс доступний на http://localhost:8080.

## Контейнер

~~~bash
docker build -t build-ship-run:v1 .
docker run -d -p 8080:8080 build-ship-run:v1
~~~

Фінальний образ на базі `scratch`, близько 19 MB. Опублікований у двох реєстрах:

- `docker.io/vchaws/build-ship-run:v1`
- `ghcr.io/chumachenko-vy/build-ship-run:v1`

## Kubernetes (kind)

~~~bash
kind create cluster --name bsr
kubectl apply -f k8s/
kubectl port-forward svc/bsr 8080:80
~~~

## Хмара (GCP)

- VM `e2-small`, Ubuntu 24.04, статична зовнішня IP-адреса
- k3s з вбудованим Traefik як Ingress
- домен `vlch.net`, DNS-зона в Cloud DNS, кожен сервіс на своєму піддомені
- HTTPS: cert-manager + Let's Encrypt (HTTP-01), автоматичне продовження сертифіката
- редирект HTTP → HTTPS через Traefik middleware
- файрвол: назовні відкриті лише порти 80 і 443, SSH тільки через IAP

~~~bash
kubectl apply -f infra/
kubectl apply -f k8s/
~~~
