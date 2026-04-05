# Первоначальный сетап mini-pc

## Подтоговка носителя для установки ОС

**WARNING**: Все команды ниже написаны под MacOS.

1. Скачиваем iso-образ Debian; Образ берем из https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/

Пример:
```bash
curl -LO https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso
```

2. Вставляем флешку в компьютер, и узнаем имя девайса.

```bash
diskutil list
```

3. Отмонтируем флешку

```bash
diskutil unmountDisk /dev/diskXXX
```

4. Записываем iso на флешку

```bash
sudo dd bs=1m if=debian-13.4.0-amd64-netinst.iso of=/dev/rdiskXXX
```

5. Отключаем девайс от компьютера

```bash
diskutil eject /dev/diskXXX
```

## Установка ОС на mini-pc

- Ставим как обычно
- Выделяем разделы:
    - `/` - 128GB
    - `swap` - 5 GB
    - `/var` - 90GB
    - `/srv` - 800GB

## Настройка ssh сервера на mini-pc

1. Настраиваем ssh на сервере

В файле `/etc/ssh/sshd_config`:
- Выключаем root-логин - `PermitRootLogin no`
- Временно разрешаем аутентификацию по паролю - `PasswordAuthentication yes`

Затем перезапускаем ssh: `systemctl restart ssh`

2. Добавляем пользователя в группу `sudo`

```bash
su -l # логинимся под root
adduser {username} sudo
```

3. Прокидываем публичный ключ для авторизации

```bash
cat ~/.ssh/id_ed25519.pub
```

и подключенными по ssh - прокидываем его:

```bash
mkdir -p ~/.ssh
echo "..." >> ~/.ssh/authorized_keys
```

4. Отключаем аутентификацию по паролю

В файле `/etc/ssh/sshd_config`:
- Выставляем `PasswordAuthentication no`

Затем перезапускаем ssh: `sudo systemctl restart ssh`
