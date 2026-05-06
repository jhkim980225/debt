# 빚 관리 앱 - 스펙 문서

이 폴더는 **빚 관리 + 동기부여 모바일 앱**의 PM 스펙 문서 모음입니다. AI 코딩 에이전트(Claude Code, Cursor 등) 또는 개발자가 읽고 구현할 수 있도록 작성됐습니다.

## 읽는 순서

1. **[CLAUDE.md](./CLAUDE.md)** — 제품 비전, 5대 원칙, AI 에이전트 행동 규칙. **항상 첫 진입점**.
2. **[SKILLS.md](./SKILLS.md)** — 기술 스택, 폴더 구조, 코딩 컨벤션
3. **docs/** — 디자인 시스템, 데이터 모델, IA, 용어집 (참조 문서)
4. **features/** — 기능별 PRD (구현 단위)

## 문서 구조

```
debt-app-spec/
├── CLAUDE.md                           ← 최상위 컨텍스트
├── SKILLS.md                           ← 기술 스택
├── README.md                           ← 이 파일
├── docs/                               ← 공통 참조
│   ├── design-system.md                ← 색상, 타이포, 토큰
│   ├── data-model.md                   ← 엔티티 정의
│   ├── information-architecture.md     ← 화면 트리, 사용자 흐름
│   └── glossary.md                     ← 용어 통일
└── features/                           ← 기능 PRD
    ├── 00-onboarding.md
    ├── 01-auth.md                      ← 회원가입/로그인
    ├── 02-debt-register.md             ← 빚 등록
    ├── 03-dashboard.md                 ← 대시보드
    ├── 04-payment-record.md            ← 상환 기록
    ├── 05-simulation.md                ← 시뮬레이션
    ├── 06-statistics.md                ← 통계
    ├── 07-badges-motivation.md         ← 배지/연속기록
    ├── 08-community-board.md           ← 게시판
    └── 09-settings.md                  ← 설정
```

## 구현 우선순위 (Phase별)

### Phase 1 — MVP 출시 (필수)
- 01-auth (회원가입/로그인)
- 02-debt-register (빚 등록)
- 03-dashboard (대시보드)
- 04-payment-record (상환 기록)
- 09-settings (필수만)

### Phase 2 — 동기부여 강화
- 07-badges-motivation
- 06-statistics
- 05-simulation

### Phase 3 — 커뮤니티
- 08-community-board

### Phase 4 — 보강
- 00-onboarding 풀버전
- 09-settings 나머지 (앱잠금, 다크모드 등)

## 각 features/*.md 문서 구성

모든 기능 문서는 다음 섹션을 포함:
- **목적 / 우선순위 / 핵심 원칙**
- **사용자 스토리 / 진입 경로**
- **화면 구성 (화면별 상세)**
- **데이터 흐름 / 검증 정책**
- **카피 디테일**
- **Edge Cases**
- **분석 이벤트**
- **관련 문서**
- **구현 체크리스트**

## AI 에이전트 사용 가이드

### 작업 시작 시
1. `CLAUDE.md` 읽기 (제품 원칙, 행동 규칙)
2. `SKILLS.md` 읽기 (기술 스택, 컨벤션)
3. 작업할 기능의 `features/*.md` 정독
4. `docs/design-system.md`, `docs/data-model.md` 참조

### 막혔을 때
- 비즈니스 룰 모호 → 해당 기능 문서의 "Edge Cases"
- 디자인 모호 → `docs/design-system.md`
- 용어 모호 → `docs/glossary.md`
- 그래도 모호 → 사용자(PM)에게 질문, 추측 금지

### 새 기능 추가 시
- `features/`에 새 마크다운 추가
- 데이터 모델 변경 시 `docs/data-model.md` 동기화
- 다른 기능과 의존성 명시

## 제품 한 줄 정의

> 개인의 빚 상환 여정을 함께하는 동반자 앱.
> 빚 등록 → 상환 추적 → 동기부여 → 커뮤니티 공유 흐름으로 사용자가 빚으로부터 자유로워지는 과정을 돕습니다.

## 5대 제품 원칙 (요약)

1. **따뜻하지만 진지함** — 빚 앱이 무겁게 느껴지면 안 열리음. 베이지+녹색 톤
2. **마찰 최소화** — 첫 빚 등록 3분, 매일 상환 기록 10초
3. **즉각적 피드백** — 행동마다 변화 시각화 (도파민 트리거)
4. **비교가 아닌 진전** — 어제의 나 vs 오늘의 나. 랭킹 X
5. **프라이버시 존중** — 로컬 우선, 동기화 옵트인, 익명 닉네임

자세한 내용은 `CLAUDE.md` 참조.
