# Design System

빚 관리 앱의 디자인 토큰 정의. 모든 UI 코드는 이 토큰만 사용.

## 디자인 철학

- **따뜻한 베이지 + 차분한 액센트**: 빚 앱이 압박감을 주지 않도록
- **빨강은 우선순위/경고에만**: 메인 색으로 쓰면 매일 열기 싫어짐
- **녹색은 진전/성공**: 진행률, 달성, 절약 표시
- **시리프 폰트는 인용구에만**: 동기부여 메시지를 살짝 다른 톤으로

## 컬러 팔레트

### 기본 (Surface)
| 토큰 | HEX | 용도 |
|------|-----|------|
| `background` | `#FAFAF7` | 앱 전체 배경 |
| `surface` | `#FFFFFF` | 카드, 입력칸 |
| `surfaceSecondary` | `#F5F5F4` | 보조 카드 |
| `surfaceTertiary` | `#F0EFEA` | 페이지 컨테이너 |

### 텍스트
| 토큰 | HEX | 용도 |
|------|-----|------|
| `textPrimary` | `#1C1B1A` | 메인 텍스트, 버튼 배경 |
| `textSecondary` | `#6B6967` | 설명, 라벨 |
| `textTertiary` | `#9C9A97` | 비활성 텍스트 |
| `textOnDark` | `#FFFFFF` | 어두운 배경 위 |

### 보더
| 토큰 | HEX |
|------|-----|
| `borderLight` | `#E8E6E3` |
| `borderMedium` | `#D4D2CF` |

### 시맨틱

#### 성공/진전 (녹색)
- `success`: `#0F6E56` — 메인
- `successLight`: `#E1F5EE` — 배경
- `successAccent`: `#97C459` — 강조 (배지 등)
- `successDark`: `#04342C` — 어두운 텍스트

#### 위험/경고 (빨강)
- `danger`: `#E24B4A` — 메인
- `dangerLight`: `#FCEBEB` — 배경
- `dangerDark`: `#791F1F` — 어두운 텍스트

#### 정보 (파랑)
- `info`: `#185FA5`
- `infoLight`: `#E6F1FB`
- `infoMedium`: `#B5D4F4`
- `infoDark`: `#0C447C`

#### 액센트 (주황) - 학자금/장기
- `accent`: `#BA7517`
- `accentLight`: `#FAEEDA`
- `accentMedium`: `#FAC775`
- `accentDark`: `#633806`

#### 보라 (지인/감성)
- `purple`: `#534AB7`
- `purpleLight`: `#EEEDFE`
- `purpleMedium`: `#CECBF6`
- `purpleDark`: `#3C3489`

#### 핑크 (할부)
- `pink`: `#D4537E`
- `pinkLight`: `#FBEAF0`
- `pinkMedium`: `#F4C0D1`
- `pinkDark`: `#72243E`

### 빚 카테고리별 색상
| 카테고리 | 색상 토큰 |
|---------|----------|
| creditCard (신용카드) | `danger` (#E24B4A) |
| studentLoan (학자금) | `accent` (#BA7517) |
| bankLoan (은행대출) | `success` (#0F6E56) |
| personal (지인) | `purple` (#534AB7) |
| installment (할부) | `pink` (#D4537E) |
| other (기타) | `textSecondary` (#6B6967) |

### 소셜 로그인 브랜드
- 카카오: `#FEE500` (배경), 검정 (전경)
- 네이버: `#03C75A` (배경), 흰색 (전경)
- Apple: `#000000` (배경), 흰색 (전경)
- Google: 흰색 (배경), 검정 (전경), 보더 있음

## 타이포그래피

### 폰트 패밀리
- **본문**: Pretendard (한글 + 영문 + 숫자)
- **인용구/감성**: Noto Serif KR (이탤릭으로)

폰트 미설치 시 시스템 폰트로 fallback.

### 텍스트 스타일

| 토큰 | 사이즈 | 굵기 | 행간 | 용도 |
|------|--------|------|------|------|
| `displayLarge` | 24 | 500 | 1.3 | 화면 메인 타이틀 |
| `displayAmount` | 28 | 500 | 1.2 | 큰 금액 표시 |
| `displayAmountMedium` | 26 | 500 | 1.2 | 중간 금액 |
| `headingLarge` | 22 | 500 | 1.3 | 섹션 제목 |
| `headingMedium` | 18 | 500 | 1.3 | 카드/모달 제목 |
| `headingSmall` | 15 | 500 | 1.3 | 앱바 타이틀 |
| `bodyLarge` | 14 | 400 | 1.6 | 일반 본문 |
| `bodyMedium` | 13 | 400 | 1.6 | 작은 본문 |
| `bodySmall` | 12 | 400 | 1.5 | 더 작은 본문 |
| `labelLarge` | 12 | 500 | 1.5 | 입력 라벨 |
| `labelSmall` | 11 | 500 | 1.5 | 작은 라벨 |
| `labelTiny` | 10 | 400 | 1.4 | 메타 정보 |
| `buttonLarge` | 14 | 500 | - | 버튼 |
| `buttonMedium` | 13 | 500 | - | 버튼 |
| `quote` | 12 | 400 (italic) | 1.6 | 인용구 (Serif) |

## 간격 (Spacing)

8pt grid 기반.

| 토큰 | 값 | 용도 |
|------|-----|------|
| `xs` | 4 | 미세 간격 |
| `sm` | 8 | 작은 간격 (아이콘-텍스트) |
| `md` | 12 | 카드 내부 간격 |
| `lg` | 16 | 표준 간격 |
| `xl` | 20 | 화면 좌우 패딩 (`screenPadding`) |
| `xxl` | 24 | 섹션 간격 |
| `xxxl` | 32 | 큰 섹션 분리 |

## 모서리 (Border Radius)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `xs` | 4 | 작은 태그/배지 |
| `sm` | 6 | 작은 칩 |
| `md` | 8 | 입력칸, 버튼, 카드 |
| `lg` | 12 | 큰 카드 |
| `xl` | 16 | 섹션 컨테이너 |
| `pill` | 999 | 칩, 진행률 바 |

## 그림자

대부분의 UI는 그림자 없이 보더로 깊이 표현. 그림자는 모달/드롭다운에만.

| 토큰 | 사용 |
|------|------|
| `shadowSm` | 떠있는 작은 카드 |
| `shadowMd` | 모달 |
| `shadowLg` | 드롭다운, 시트 |

## 애니메이션

| 토큰 | 값 | 용도 |
|------|-----|------|
| `durationFast` | 150ms | 색상 변화, 호버 |
| `durationNormal` | 250ms | 화면 전환, 펼침 |
| `durationSlow` | 400ms | 페이지 진입 |

기본 곡선: `Curves.easeOutCubic`

## 컴포넌트 패턴

### 입력칸 (Input)
- 보더 0.5px, 라운드 8
- 포커스 시 보더 1.5px, 색상 `textPrimary`
- 라벨 위에 표시, `labelLarge` 스타일
- 에러 메시지 아래 표시, `bodySmall` + `danger` 색

### 버튼
- 모든 버튼 높이 최소 48px (터치 영역)
- 메인 액션: `textPrimary` 배경, 흰 텍스트
- 보조 액션: 투명 배경, `borderMedium` 보더
- 텍스트 액션: 배경 없음, `textPrimary` 텍스트
- 비활성: opacity 0.4

### 카드
- 배경: `surface`
- 보더: 0.5px `borderLight` (시각적 분리용)
- 라운드: `lg` (12)
- 내부 패딩: `lg` (16) 표준

### 칩 (Chip)
- 라운드: `pill`
- 미선택: `surfaceSecondary` 배경, `textSecondary` 텍스트
- 선택: 흰 배경 + 2px `textPrimary` 보더 + 굵은 텍스트
- 패딩: 좌우 14, 상하 6

### 진행률 바
- 높이: 8 (대시보드), 4 (인라인 작은 표시)
- 라운드: 높이의 절반
- 배경: `surfaceSecondary`

### 정보 카드 (4가지 톤)
배경+텍스트 색상 페어:
- success: `successLight` + `success`
- info: `infoLight` + `infoDark`
- warning: `accentLight` + `accentDark`
- purple: `purpleLight` + `purpleDark`
- neutral: `surfaceSecondary` + `textSecondary`

## 아이콘

- 표준 사이즈: 16, 18, 20, 24
- 라이브러리: Material Icons + 필요시 커스텀 SVG
- 색상은 위치한 텍스트 색상과 동일

## 모바일 화면 너비 가이드

- 최소 지원: 360px
- 디자인 기준: 380px
- 패딩: 좌우 20px (`screenPadding`)
- 컨텐츠 최대 너비: 화면 너비 - 40

## 다크모드

**Phase 1에서는 라이트 모드만 지원.** Phase 4 이후 다크모드 추가 시 별도 토큰 정의 필요.
