# SKILLS.md

기술 스택, 도구, 코딩 컨벤션을 정의합니다.

## 기술 스택

### 프론트엔드
- **프레임워크**: Flutter 3.16+
- **언어**: Dart 3.2+
- **타겟 플랫폼**: iOS 14+, Android 8+ (API 26+)
- **최소 화면 너비**: 360px

### 상태관리
- **선택**: Riverpod 2.x (`flutter_riverpod`)
- **이유**: Provider보다 타입 안전성 강하고 테스트 용이. 빚 데이터처럼 복잡한 상태 관리에 적합.
- **패턴**: `StateNotifier` + `Provider` 조합

### 로컬 저장
- **빚 데이터**: Hive (NoSQL, 빠름, 타입 안전)
- **간단 설정**: SharedPreferences
- **이유**: 사용자 빚은 민감 정보 → 로컬 우선

### 백엔드 (커뮤니티 기능 시작 시)
- **선택**: Supabase
- **이유**:
  - PostgreSQL 기반 (마이그레이션 자유로움)
  - 인증/RLS/실시간 기본 제공
  - 한국에서 안정적, Firebase보다 비용 저렴
- **인증**: Supabase Auth + 카카오는 별도 OAuth 구현

### 차트
- **선택**: `fl_chart` 0.66+
- **사용처**: 대시보드 진행률, 통계 월별 그래프, 시뮬레이션 라인 차트

### 주요 패키지
```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  fl_chart: ^0.66.0
  intl: ^0.19.0           # 날짜/숫자 포맷
  go_router: ^13.0.0      # 네비게이션
  supabase_flutter: ^2.0.0 # Phase 3 이후
  flutter_secure_storage: ^9.0.0  # 토큰 저장
  local_auth: ^2.1.7      # 생체인증 (앱 잠금)
```

## 폴더 구조

```
lib/
├── main.dart
├── app.dart                    # MaterialApp + 라우팅
├── core/
│   ├── theme/                  # 디자인 시스템 (docs/design-system.md 참조)
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_tokens.dart
│   │   └── app_theme.dart
│   ├── widgets/                # 재사용 위젯
│   ├── utils/                  # 헬퍼 (포매터, 계산기 등)
│   └── constants/              # 상수
├── features/                   # 기능별 모듈 (features/*.md 1:1 매핑)
│   ├── auth/
│   │   ├── data/               # repository, datasource
│   │   ├── domain/             # model, usecase
│   │   └── presentation/       # screen, widget, controller
│   ├── debt_register/
│   ├── dashboard/
│   ├── payment_record/
│   ├── simulation/
│   ├── statistics/
│   ├── badges/
│   ├── community/
│   └── settings/
└── routes/
    └── app_router.dart         # go_router 정의
```

각 feature 폴더는 **Clean Architecture 3-layer** 구조를 따릅니다:
- `data/`: Hive/Supabase와의 통신, DTO
- `domain/`: 비즈니스 로직, 모델 (UI/DB 독립)
- `presentation/`: 화면, 위젯, Riverpod 컨트롤러

## 코딩 컨벤션

### 네이밍
- **파일명**: `snake_case.dart`
- **클래스**: `PascalCase`
- **변수/함수**: `camelCase`
- **상수**: `lowerCamelCase` (`final`/`const` 사용)
- **Private**: `_underscore` prefix

### 위젯
- **단일 위젯 = 단일 파일**. 한 파일에 100줄 넘으면 분리 고려.
- **`StatelessWidget` 우선**. 상태가 필요하면 Riverpod로.
- `const` 생성자 적극 사용 (성능).
- 위젯 내부 빌드 메서드는 `_build...()` 형식.

### 주석
- **공개 API에는 dartdoc 주석** (`///`)
- **복잡한 로직에는 한국어 주석** OK
- **TODO 주석은 이슈 번호와 함께**: `// TODO(#42): 캐시 추가`

### 에러 처리
- 사용자 노출 메시지는 한국어, 친절하게.
- 기술적 에러는 로그로만.
- `try/catch`보다 `Result<T, E>` 패턴 권장 (`fpdart` 등).

### 테스트
- 비즈니스 로직(domain)은 단위 테스트 필수.
- 위젯 테스트는 핵심 플로우만.
- 통합 테스트는 Phase 4 이후.

## 디자인 시스템 사용

**디자인 토큰 외 색상/사이즈 하드코딩 금지.**

```dart
// ❌ 잘못됨
Container(color: Color(0xFF1C1B1A), padding: EdgeInsets.all(16))

// ✅ 올바름
Container(color: AppColors.textPrimary, padding: EdgeInsets.all(AppSpacing.lg))
```

자세한 토큰은 `docs/design-system.md` 참조.

## 라우팅

`go_router` 기반. 라우트 정의는 `lib/routes/app_router.dart` 한 곳에서.

주요 라우트:
- `/` → 스플래시
- `/onboarding` → 온보딩
- `/auth/login`, `/auth/signup`, `/auth/reset-password`
- `/home` → 대시보드 (탭 컨테이너)
  - `/home/dashboard`
  - `/home/badges`
  - `/home/community`
  - `/home/settings`
- `/debt/add` → 빚 등록 (모달)
- `/debt/:id` → 빚 상세
- `/payment/record` → 상환 기록 (모달)
- `/simulation`
- `/statistics`

## 다국어 (i18n)

- **Phase 1-3**: 한국어만
- **Phase 4 이후**: `flutter_localizations` + `intl` 도입
- 모든 사용자 노출 문자열은 처음부터 상수로 분리 (나중에 키로 변환 쉽게)

## 성능 가이드

- 빌드 메서드 안에서 무거운 계산 금지 → `useMemo` 패턴 또는 Riverpod의 `Provider` 사용
- `ListView.builder` 항상 사용 (정적 리스트도)
- 이미지는 `cached_network_image` 패키지로 캐싱
- 차트 데이터는 `Provider`로 메모이제이션

## 보안 가이드

- 토큰은 `flutter_secure_storage`에 저장 (절대 SharedPreferences X)
- API 키는 `--dart-define`으로 빌드 시 주입, 코드 커밋 금지
- 사용자 입력은 모두 검증 (특히 금액 입력)
- HTTPS 외 통신 금지

## CI/CD (Phase 2 이후)

- **Lint**: `flutter analyze` 빌드 단계에서 실패 처리
- **테스트**: PR 단계에서 자동 실행
- **빌드**: Codemagic 또는 GitHub Actions

## AI 에이전트 사용 가이드

### 코드 생성 요청 시 따라야 할 것
1. 항상 `docs/design-system.md`의 토큰 사용
2. 새 화면은 `features/` 안의 해당 기능 문서 정독 후 작업
3. 데이터 모델은 `docs/data-model.md`와 일치시킴
4. 의존성 추가 시 사전 확인 (이 문서의 패키지 목록)

### 모르는 것은 추측하지 말 것
- 디자인이 명확하지 않으면 → `docs/design-system.md` 확인
- 비즈니스 룰이 모호하면 → 해당 `features/*.md`의 "Edge Cases" 섹션 확인
- 그래도 모르면 → 사용자에게 질문, 추측으로 진행 금지
