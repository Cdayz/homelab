# HomeLab

Репозиторий для Infrastructure-as-a-Code конфигурации домашней лаборатории.

## Особенности

- Everything as a Code - храним все в виде кода и конфигураций в репозитории
- Разделение на:
    - control-plane - личное устройство с которого управляется homelab
    - data-plane - мини-пк выступающий в роли homelab сервера

## Процесс разработки

- Вся конфигурация связанная с системой распологается в папке [nixos](./nixos/)
- Система предоставляет 2 основных сервиса:
    - Nomad - в качестве оркестратора всей нагрузки
    - Caddy - в качестве единственного Reverse Proxy

- Вся не-системная нагрузка, доставляется в виде nomad job'ов располагающихся в подпапках [nomad/jobs](./nomad/jobs/)
- Инструкции по добавлению новых Nomad Job'ов можно найти в [тут](./nomad/README.md)

## Деплой приложений

- `task nucbox:rebuild` - пересборка и настройка NixOS из репозитория на сервер
- `task nucbox:nomad:deploy -- app` - деплой Nomad-job'ы app на сервер

## Добавление БД в PostgreSQL

1. `task postgres:create-migration -- {{имя-миграции}}` - добавляем миграцию для инициализации пользователя

Код миграции для инициализации пользователя:
```sql
DO $$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'myuser') THEN

      RAISE NOTICE 'Role "myuser" already exists. Skipping.';
   ELSE
      CREATE USER myuser PASSWORD NULL;
   END IF;
END $$;
```

Код миграции для де-инициализации пользователя:
```sql
DO $$
BEGIN
    IF EXISTS (
        SELECT FROM pg_user WHERE usename = 'myuser'
    ) THEN
        DROP USER myuser;
    END IF;
END $$;
```

2. `task postgres:create-migration -- {{имя-миграции}}` - добавляем миграцию для инициализации базы данных

Код миграции для инициализации базы данных:
```sql
CREATE EXTENSION IF NOT EXISTS dblink;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_database WHERE datname = 'mydb'
    ) THEN
        PERFORM dblink_exec('dbname=' || current_database()  -- current db
                        , 'CREATE DATABASE mydb OWNER myuser;');
    END IF;
END $$;
```

Код миграции для де-инициализации базы данных:
```sql
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_database WHERE datname = 'mydb'
    ) THEN
        PERFORM dblink_exec('dbname=' || current_database()  -- current db
                        , 'DROP DATABASE mydb;');
    END IF;
END $$;
```

3. Прогоняем миграцию `task nucbox:postgres:apply-migrations`

4. Инициализируем пароль в БД:

```bash
ssh -L 15432:localhost:15432 -N -f nikita@192.168.1.136 # Подключаем port-forward в БД
pgcli postgresql://postgres:$PASSWORD@127.0.0.1:15432/postgres # Подключаемся к БД
```

Выполняем в БД:
```sql
alter user myuser PASSWORD 'replace-me';
```

Далее пароль заносим в sops-секреты для приложения.
