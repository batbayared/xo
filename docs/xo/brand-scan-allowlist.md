# Брэнд скан: зориуд үлдээсэн «Paperclip» тохиолдол

Скан: `pnpm xo:brand-scan` (scripts/xo-brand/scan.mjs). Скан нь ui/src (.ts, .tsx) ба
server/src/onboarding-assets (.md) доторх том үсгээр эхэлсэн «Paperclip» үгийг тоолж,
scripts/xo-brand/baseline.json-оос давсан файлыг алдаа гэж үзнэ. Тусдаа allowlist файл
дэмждэггүй тул baseline.json нь зөвшөөрөгдсөн тоог хадгалж, энэ баримт ангиллыг тайлбарлана.

PAPERCLIP_* орчны хувьсагч, X-Paperclip-* header, @paperclipai багц, paperclipai CLI-г
скан тоолдоггүй (жижиг үсэг эсвэл зураас залгаатай тул regex таардаггүй).

## Төлөв (2026-10-22)

65 файл, 114 тохиолдол (2026-10-28). Хэрэглэгчид харагдах, аюулгүй солих боломжтой тохиолдол олдсонгүй.

| Ангилал | Тоо | Яагаад үлдээсэн |
|---|---:|---|
| lucide-react «Paperclip» (хавчаар) дүрс | 37 | Дүрсний компонентын нэр. Хавсралтын тэмдэг, брэнд биш. 15 файл: import ба JSX хэрэглээ. |
| Кодын тайлбар (comment, JSDoc) | 57 | Хэрэглэгчид харагдахгүй. Upstream-ийн тайлбарыг хөндвөл синкийн зөрчил нэмэгдэнэ. |
| Серверийн англи текст тааруулах literal | 9 | Сервер «Paperclip ...» гэж бичсэн мессежийг яг тааруулж орчуулна: xo/serverMessage.ts (2), xo/labels.ts (4), lib/successful-run-handoff.ts (3). Солиход тааруулалт эвдэрнэ. |
| UX lab fixture | 11 | fixtures/systemNoticeFixtures.ts: SystemNoticeUxLab хуудасны жишээ өгөгдөл, серверийн мэдэгдлийг дуурайна. |
| **Нийт** | **114** | |

## Тэмдэглэл

- ConnectionSetupFlow.tsx-ийн GitHub App-ийн хоёр текстийг 2026-10-28-нд «the GitHub App» болгож, tx()-ээр ороосон
  (App-ийн нэрийг заахгүй тул GitHub-ийн managed App солигдсон ч зөв хэвээр).
- Upstream синкийн дараа скан baseline-аас давбал шинэ тохиолдлыг дээрх ангиллаар шүүнэ:
  хэрэглэгчид харагдах текст бол XO болгож засна, бусад тохиолдолд
  `node scripts/xo-brand/scan.mjs --update`-аар baseline шинэчилнэ.
