# HW1

## 1. Проверил, что Docker установлен и работает

Выполнил команду:

```bash
docker ps
```

Появилась информация о контейнерах.

---

## 2. Скачал Docker image

Выполнил команду:

```bash
docker pull docker.io/vldbuk/gpdb_demo_repo:gpdb_demo
```

---

## 3. Проверил наличия image

Выполнил команду:

```bash
docker images
```

В списке появился образ:

```text
vldbuk/gpdb_demo_repo:gpdb_demo
```

---

## 4. Запустил контейнер

Запустил контейнер командой:

```bash
docker run -ti -d --privileged=true -p 5432:5432 docker.io/vldbuk/gpdb_demo_repo:gpdb_demo "/usr/lib/systemd/systemd"
```

---

## 5. Проверил, что контейнер запущен

Выполнил команду:

```bash
docker ps
```

В выводе появился контейнер с `IMAGE` = `vldbuk/gpdb_demo_repo:gpdb_demo`. Скопировал его `CONTAINER ID`.

---

## 6. Подключение к контейнеру

Используя `CONTAINER ID`, подключился к контейнеру:

```bash
docker exec -it <CONTAINER ID> bash
```

---

## 7. Переключение на пользователя gpadmin

Внутри контейнера выполнил:

```bash
su gpadmin
```

---

## 8. Запустил Greenplum 

Запустил Greenplum командой:

```bash
gpstart -qa
```

---

## 9. Подключение к базе demo

После запуска GPDB подключитесь к базе `demo` через консольный клиент:

```bash
psql -d demo
```
