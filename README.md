# HomeLab

Репозиторий для Infrastructure-as-a-Code конфигурации домашней лаборатории.

## Особенности

- Everything as a Code - храним все в виде кода и конфигураций в репозитории
- Разделение на:
  - control-plane - личное устройство с которого управляется homelab
  - data-plane - мини-пк выступающий в роли homelab сервера

## Процесс разработки

- Вся конфигурация связанная с системой распологается в папке [nixos](./nixos/)

## Сеть (nucbox)

Сеть настраивается через systemd-networkd (`nixos/modules/network/`):

- `br0` — бридж из `enp3s0` (uplink) и `eno1`, основной линк, DHCP
- `wlp2s0` — wifi (mt7921e), запасной линк: работает и без lan-провода
- route-метрики: провод (100) приоритетнее wifi (300), при обрыве провода
  трафик уходит на wifi
- `wait-online --any` — boot не висит на сетевом линке, если провод не воткнут
- `arp_ignore=1` / `arp_announce=2` — оба линка в одном L2, без этого ядро
  отвечает на ARP за чужой интерфейс и ssh по lan деградирует

### Split-VPN (antizapret + openai через AmneziaWG)

`nixos/modules/services/split-vpn/` — прозрачный egress-сплит на хосте:

- **amneziawg 3.1** (kernel-модуль, `awg0`, `Table=off` + policy-route таблица 51820)
  — обфускация против DPI: классический WireGuard из РФ режется на data-пакетах
- **sing-box** (tun `split-vpn` + `auto_redirect`): SNI-sniffing, DNS-хайджек;
  antizapret-список (remote rule-set, автообновление) + openai-домены → `via-awg`;
  остальное → direct; github всегда direct (иначе чинилка VPN зависит от VPN)
- DNS: заблокированные/openai — Quad9 DoH через туннель; остальное — роутер; `ipv4_only`
- секрет `vpn/awg-conf` — wg.conf провайдера целиком в sops, `render-awg.py`
  добавляет `Table=off`/маршруты; `make-singbox.py` генерирует конфиг sing-box
- модуль грузится `modprobe -d /run/current-system/kernel-modules` (autoload не работает,
  а `rebuild:test` не обновляет booted-system)

Грабли, на которые наступили (не повторять): IPv6 до Fastly из РФ битый — на линках
`IPv6AcceptRA=false`; udev-переименование wifi — только матч по MAC с явным `Name=`;
`PostUp/PreDown` обязаны быть в `[Interface]`.

### WiFi-пароль

PSK хранится только в sops (`nixos/secrets/nucbox.yaml`, ключ `wifi/psk`) и
рендерится в `/run/secrets/rendered/wifi.env`; в nix store попадает лишь
ссылка `ext:wifi_psk`. SSID лежит в конфиге открыто — он не секрет.

Смена пароля от wifi:

```bash
# nixos/secrets/nucbox.raw.yaml → wifi.psk
task sops:encrypt
task nucbox:rebuild
```

### Доступ с control-plane

`ssh nucbox` работает по любому из доступных линков: ssh перебирает адреса,
если имя резолвится в несколько A-записей. Настраивается на control-plane так:

`/etc/hosts`:

```
192.168.1.136 nucbox   # br0, lan
192.168.1.40  nucbox   # wlp2s0, wifi
```

`~/.ssh/config`:

```
Host nucbox
	User nikita
	Port 22
	SetEnv TERM=xterm
	ConnectTimeout 3
```

`ConnectTimeout` нужен, чтобы фейловер на wifi при обрыве провода не висел
в системном tcp-таймауте.

Деплой без провода: `task nucbox:rebuild NUCBOX_HOST=192.168.1.40`.
