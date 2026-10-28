# XO пилотын бэлтгэлийн хуудас (Ү5)

Ү5-ын D2–D6 ажлыг ED-ийн Mac дээр хийхэд дагах дараалал. Нууц түлхүүр, нууц үг, бүртгэл, DNS-ийг ED өөрөө оруулна.

## 1. Mac бэлтгэл (D2)

- [x] (2026-10-22) Унтахгүй байх: `sudo pmset -c sleep 0 disksleep 0` (цэнэглэгчтэй үед). Дэлгэц унтаж болно.
- [x] Чөлөөт зай ≥ 20 GB: `df -h /Users/Shared`. 2026-10-28: 25 GiB чөлөөтэй (94% дүүрсэн), босгоос ахиу бага.
- [x] (2026-10-22, xo-v2026.10.22) Release tag: `git tag xo-v2026.10.DD && git push origin xo-v2026.10.DD` (push бүрд ED зөвшөөрнө).
- [x] Пилотын хавтас home-оос гадна (2026-10-22, sudo-гүй үүссэн; claude-config хавтсыг мөн үүсгэ):

```bash
sudo mkdir -p /Users/Shared/xo/logs /Users/Shared/xo/claude-config /Users/Shared/xo-backups
sudo chown -R "$USER" /Users/Shared/xo /Users/Shared/xo-backups
chmod 700 /Users/Shared/xo /Users/Shared/xo-backups
```

- [x] Instance (2026-10-22, `onboard -y --no-install-service`; loopback 127.0.0.1:3100, DB порт 54329):

```bash
export XO_HOME=/Users/Shared/xo
export XO_INSTANCE_ID=xo-pilot
pnpm paperclipai onboard
```

## 2. Агентын санах ойн тусгаарлалт (D4)

**Асуудал** (2026-10-12, CMP-4): пилот агент операторын ~/.claude/CLAUDE.md дахь хувийн зааврыг дагасан.

**Шинэ олдвор** (2026-10-22, код уншиж тогтоосон, туршаагүй): managed AI холболттой агентад claude-local adapter `--setting-sources user` дамжуулдаг (packages/adapters/claude-local/src/server/execute.ts:885, acp.ts:631). Энэ нь хэрэглэгчийн түвшний тохиргоог, өөрөөр хэлбэл агентыг ажиллуулж буй OS хэрэглэгчийн ~/.claude-г уншуулна. Тэгэхээр XO_HOME-ийг /Users/Shared/xo руу зөөх нь төслийн түвшний CLAUDE.md-ийн алхалтыг таслах ч хэрэглэгчийн ~/.claude/CLAUDE.md-ийг таслахгүй байх магадлалтай.

Сонголтууд, найдвартай байдлын дарааллаар:

1. **Тусдаа OS хэрэглэгч** (жишээ `xo`), өөрийн хоосон HOME-тэй. XO server-ийг тэр хэрэглэгчээр ажиллуулна. Баталгаатай, гэхдээ тохируулга их.
2. **Server процессод CLAUDE_CONFIG_DIR тавих** (2026-10-22-нд сонгож, server plist-д тавьсан; тест хүлээгдэж байна): `CLAUDE_CONFIG_DIR=/Users/Shared/xo/claude-config` (хоосон хавтас, CLAUDE.md-гүй). Managed холболт API түлхүүр хэрэглэдэг тул операторын нэвтрэлт шаардахгүй. Хялбар, гэхдээ доорх тестээр батлах ёстой.

**Тусгаарлалтын тест** (сонголтоо хийсний дараа заавал):

- [x] Пилот компанид нэг богино task үүсгэ: «Чиний ачаалсан CLAUDE.md файлуудын замыг жагсаа, агуулгыг бүү хуул». (2026-10-28: XO-19, QCLead-д оноосон.)
- [ ] Хариунд /Users/batbayardavaanyam/.claude/CLAUDE.md эсвэл Монгол хэлний дүрэм гарч ирвэл тусгаарлалт ажиллаагүй.
- [ ] Үр дүнг энэ файлд огноотой тэмдэглэ.

**2026-10-28-ны үр дүн (хагас):** Агентын тест дуусаагүй. XO-19-ийн run 8637eb02 ба 2a3ad670 хоёулаа «ACP agent reported a terminal limit failure» (acpx_turn_failed, exit 1) алдаагаар унасан, stderr хоосон; 10-22-ны run-ууд ч мөн адил. Тиймээс агентын хариугаар батлах боломжгүй байна. Файлын түвшний шалгалт цэвэр гарсан: /Users/Shared/xo/claude-config-д зөвхөн .claude.json ба backups/ байгаа, CLAUDE.md байхгүй; агентын ажлын хавтас /Users/Shared/xo/instances/xo-pilot/workspaces/<agent>/ ба түүний дээд хавтсуудад (/Users/Shared/xo, /Users/Shared, /Users) CLAUDE.md байхгүй; adapter --setting-sources user дамжуулдаг. Run-ий алдааг засаад тестийг дахин ажиллуулна (XO-19 retry дараалалд байгаа).

## 3. Нөөцлөлт (D3)

- **Цаг тутмын DB dump:** server өөрөө хийдэг (database.backup: анхдагч 60 минут, 30 хоног; PAPERCLIP_DB_BACKUP_* хувьсагчаар өөрчилнө). Dump: `<instance>/data/backups/*.sql.gz`.
- **Өдөр тутмын хуулбар:** scripts/xo-ops/daily-backup.sh. Шинэ dump авч, instance-ийн файлуудыг (secrets мастер түлхүүр, компанийн storage, workspaces, run log) /Users/Shared/xo-backups/YYYY-MM-DD руу хуулж, 14 хоногоос хуучныг устгана. Ажиллаж буй postgres хавтсыг (db/) хуулдаггүй.
- 2026-10-22-нд y3-close instance дээр туршсан: dump 697 KB, хуулбар 2.5 MB.
- [ ] Хуулбарыг Mac-аас гадагш (гадаад диск эсвэл шифрлэсэн cloud) гаргах эсэхийг ED шийднэ. secrets/ хавтас мастер түлхүүртэй тул шифрлэлтгүй cloud руу бүү хуул.

**Сэргээлтийн дасгал (D6):**

```bash
gunzip -c /Users/Shared/xo-backups/YYYY-MM-DD/instance/data/backups/<файл>.sql.gz | psql "postgres://paperclip:paperclip@127.0.0.1:<туршилтын порт>/paperclip"
```

- [ ] Туршилтын instance руу сэргээж, компани, агент, issue харагдаж байгааг шалга.
- [ ] secrets/ хавтсыг хамт сэргээгээгүй бол нууц утгууд уншигдахгүйг баталгаажуул.

## 4. Health check (D3)

- scripts/xo-ops/healthcheck.sh: /api/health-ийг шалгаж, дараалсан 3 алдааны дараа macOS мэдэгдэл гаргана. XO_LAUNCHD_LABEL тавьсан бол тэр launchd job-ийг дахин эхлүүлнэ.
- Порт пилотод өөр бол XO_HEALTH_URL-ийг тохируул (анхдагч http://127.0.0.1:3100/api/health).

## 5. launchd суулгах

Загварууд: scripts/xo-ops/launchd/. __REPO__ ба __NODE_BIN__-ийг орлуулаад:

```bash
NODE_BIN="$(dirname "$(which node)")"; REPO="$HOME/dev/paperclip-mn"
for f in backup health; do
  sed -e "s#__REPO__#$REPO#g" -e "s#__NODE_BIN__#$NODE_BIN#g" \
    "$REPO/scripts/xo-ops/launchd/com.ateamgpt.xo.$f.plist" > "$HOME/Library/LaunchAgents/com.ateamgpt.xo.$f.plist"
  launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.ateamgpt.xo.$f.plist"
done
```

**macOS TCC.** launchd-ийн /bin/bash ~/Desktop (iCloud) доторх скриптийг уншиж чадахгүй (exit 126, "Operation not permitted"). Repo Desktop дотор байвал скриптийг /Users/Shared/xo/ops руу хуулж, plist-ийн ProgramArguments-ийг тийш заа. Скрипт repo-д өөрчлөгдвөл дахин хуул:

```bash
mkdir -p /Users/Shared/xo/ops && cp "$REPO/scripts/xo-ops/healthcheck.sh" /Users/Shared/xo/ops/ && chmod +x /Users/Shared/xo/ops/healthcheck.sh
```

- [x] Health суусан (2026-10-28): /Users/Shared/xo/ops/healthcheck.sh, 5 минут тутам, last exit 0. Амжилттай шалгалт лог бичдэггүй; health.log-д зөвхөн алдаа орно (22:40-ийн 126 мөр нь TCC засварын өмнөх).
- [x] Шалгах: `launchctl print gui/$(id -u)/com.ateamgpt.xo.health | grep -E "state|runs|last exit"`.
- [ ] Backup job суугаагүй (нөөцийн шийдвэрийг хүлээж байна).
- Лог: /Users/Shared/xo/logs/{backup,health}.log.
- Health plist-д `XO_LAUNCHD_LABEL=com.ateamgpt.xo.server` нэмбэл health алдаа гарахад server-ийг дахин эхлүүлнэ.

**Server job (D2).** com.ateamgpt.xo.server.plist нь `run --instance xo-pilot`-ийг XO_HOME, CLAUDE_CONFIG_DIR (D4), PAPERCLIP_SERVICE_MANAGED=1-тэй ажиллуулна; RunAtLoad + KeepAlive. CLI-ийн `--install-service`-ийг хэрэглэхгүй: тэр нь ~/.local/bin/paperclipai shim шаарддаг, CLAUDE_CONFIG_DIR дамжуулдаггүй. Суулгахын өмнө гараар асаасан server-ээ зогсоо (порт 3100, 54329).

```bash
f=server
sed -e "s#__REPO__#$REPO#g" -e "s#__NODE_BIN__#$NODE_BIN#g" \
  "$REPO/scripts/xo-ops/launchd/com.ateamgpt.xo.$f.plist" > "$HOME/Library/LaunchAgents/com.ateamgpt.xo.$f.plist"
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.ateamgpt.xo.$f.plist"
```

- [x] Суусан (2026-10-22): state = running, `/api/health` → ok. Лог: /Users/Shared/xo/logs/server.log.
- Зогсоох: `launchctl bootout gui/$(id -u)/com.ateamgpt.xo.server`. Шинэ код татсны дараа: `launchctl kickstart -k gui/$(id -u)/com.ateamgpt.xo.server`.

## 6. Пилотын өмнөх эцсийн шалгалт

- [ ] Tailscale-ээр гаднаас нэвтрэх (D1, ED).
- [ ] Пилот хэрэглэгч бүрд компани, урилга, 20–50 USD төсөв (D5).
- [ ] 24 цаг тасралтгүй ажиллаж, health.log-д алдаагүй (D6).
- [ ] Дор хаяж нэг өдрийн хуулбар үүсч, сэргээлтийн дасгал амжилттай (D6).
