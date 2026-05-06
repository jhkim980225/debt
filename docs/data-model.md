# Data Model

앱 전체에서 사용하는 데이터 구조 정의.

## 저장 전략

- **로컬 우선**: 빚 데이터는 사용자 기기에만 저장 (Hive)
- **클라우드 동기화**: 사용자가 명시적으로 "동기화 켜기" 했을 때만 (Phase 3)
- **커뮤니티 데이터**: 항상 서버 (Supabase)
- **인증 토큰**: `flutter_secure_storage`

## 핵심 엔티티

### User (사용자)

```yaml
id: string (uuid)
email: string
displayName: string         # 닉네임 (자동 생성 또는 사용자 선택)
profileImageUrl: string?    # 선택
authProvider: enum          # email, kakao, google, apple, naver
createdAt: datetime
lastLoginAt: datetime
totalDaysActive: int        # "38일째 사용중"
streakCount: int            # 현재 연속 상환 일수
longestStreak: int          # 최고 연속 기록
strategy: enum              # snowball, avalanche
monthlyBudget: int?         # 월 상환 가능 금액 (시뮬레이션용)
```

### Debt (빚)

```yaml
id: string (uuid)
userId: string
name: string                # 사용자 정의 이름 (예: "신용카드 A")
category: enum              # creditCard, studentLoan, bankLoan, personal, installment, other
initialAmount: int          # 처음 빌린 금액 (선택, 진행률 계산용)
currentBalance: int         # 현재 남은 잔액
interestRate: double        # 연 이자율 % (0~100)
minimumPayment: int?        # 매달 최소 상환액
targetPayment: int?         # 매달 목표 상환액
paymentDay: int?            # 매달 결제일 (1-31, 또는 -1 = 말일)
notificationTiming: enum    # threeDaysBefore, sameDay, none
isPaidOff: bool             # 졸업 여부
createdAt: datetime
paidOffAt: datetime?        # 완납 일시
priority: int               # 자동 계산 (전략 기반 우선순위)
```

#### 카테고리 enum
- `creditCard`: 신용카드
- `studentLoan`: 학자금
- `bankLoan`: 은행대출
- `personal`: 지인
- `installment`: 할부
- `other`: 기타

#### 검증 규칙
- `currentBalance >= 0`
- `interestRate >= 0 && interestRate <= 100`
- `name.length >= 1 && name.length <= 30`
- `initialAmount`가 있으면 `currentBalance <= initialAmount` 권장 (강제는 아님)

### Payment (상환 기록)

```yaml
id: string (uuid)
userId: string
debtId: string              # 어떤 빚에 갚았는지
amount: int                 # 갚은 금액
paidAt: datetime            # 갚은 일시 (사용자 입력 가능)
note: string?               # 메모 (예: "보너스로 추가 상환")
isExtra: bool               # 목표보다 더 갚았는지 (배지 트리거)
createdAt: datetime         # 기록 일시 (실제 입력 시점)
balanceBefore: int          # 갚기 전 잔액
balanceAfter: int           # 갚은 후 잔액
```

### Badge (배지)

```yaml
id: string                  # 배지 식별자 (firstStep, sevenDayStreak 등)
userId: string
earnedAt: datetime
```

#### 배지 종류 (마스터 데이터)
| ID | 이름 | 조건 |
|----|------|------|
| `firstStep` | 첫 걸음 | 첫 상환 기록 |
| `sevenDayStreak` | 7일 연속 | 7일 연속 상환 |
| `thirtyDayStreak` | 30일 연속 | 30일 연속 상환 |
| `hundredDayStreak` | 100일 연속 | 100일 연속 상환 |
| `tenPercentClear` | 10% 클리어 | 전체 빚의 10% 상환 |
| `quarterClear` | 25% 클리어 | 25% 상환 |
| `halfClear` | 50% 클리어 | 50% 상환 |
| `million` | 100만원 | 누적 100만원 상환 |
| `fiveMillion` | 500만원 | 누적 500만원 상환 |
| `tenMillion` | 1000만원 | 누적 1000만원 상환 |
| `interestSaver` | 이자 절약가 | 최소 결제 대비 이자 10만원 절약 |
| `firstGraduation` | 첫 졸업 | 첫 빚 완납 |
| `allCleared` | 자유 | 모든 빚 완납 |
| `comeback` | 컴백 | 7일 이상 끊긴 후 다시 시작 |
| `extraEffort` | 한 걸음 더 | 목표보다 많이 갚기 5회 |
| `disciplined` | 꾸준함 | 30일간 매일 정확히 목표 금액 |
| `earlyBird` | 일찍 일어나는 새 | 결제일 3일 전 미리 갚기 5회 |
| `weekendWarrior` | 주말 전사 | 주말에 상환 5회 |

총 18개. 신규 배지 추가 시 이 표 업데이트.

### Streak (연속 기록)

별도 엔티티가 아닌 User 안의 필드로 관리하지만, 계산 로직 중요:

- 매일 자정 기준으로 체크
- 사용자 시간대 기준 (디바이스 시간)
- "상환했다 = 그날 Payment 1건 이상" → streak +1
- 하루 건너뛰면 → streak 0으로 리셋
- 사용자에게 "오늘 안 갚으면 끊겨요" 알림 보내야 함 (밤 9시 등)

## 커뮤니티 엔티티 (Phase 3)

### Post (게시글)

```yaml
id: string (uuid)
authorId: string
authorDisplayName: string
authorStreakCount: int      # 작성 시점 streak (배지로 표시)
category: enum              # free, question, certify, save, sidejob, finance, horror
title: string
content: string             # 본문 (마크다운 또는 plain)
imageUrls: string[]         # 첨부 이미지
isAnonymous: bool           # 작성 시 익명 옵션
debtRange: string?          # 인증글일 때 "1000만원대" 등 범위
progressPercent: int?       # 인증글일 때 진행률 (정확 금액 X)
viewCount: int
likeCount: int
commentCount: int
isHot: bool                 # 자동 (조회수/좋아요 임계 넘으면)
isEditorPick: bool          # 수동 (운영자가 선정)
isPinned: bool              # 공지 등 상단 고정
createdAt: datetime
updatedAt: datetime
deletedAt: datetime?        # 소프트 삭제
```

#### 카테고리 enum
| ID | 한글 | 색상 |
|----|------|------|
| `free` | 자유 | neutral |
| `question` | 질문 | pink |
| `certify` | 인증 | accent |
| `save` | 절약 | success |
| `sidejob` | 부업 | purple |
| `finance` | 금융정보 | info |
| `horror` | 공포의빚 | danger |

### Comment (댓글)

```yaml
id: string (uuid)
postId: string
parentCommentId: string?    # 대댓글 (1단계만 허용)
authorId: string
authorDisplayName: string
content: string
likeCount: int
isAnonymous: bool
createdAt: datetime
deletedAt: datetime?
```

### Like (좋아요)

```yaml
userId: string
targetType: enum            # post, comment
targetId: string
createdAt: datetime
```

### Report (신고)

```yaml
id: string (uuid)
reporterId: string
targetType: enum            # post, comment, user
targetId: string
reason: enum                # spam, harmful, misinfo, harassment, other
detail: string?
status: enum                # pending, reviewed, resolved
createdAt: datetime
```

## 계산 필드 (Derived)

엔티티에 저장하지 않고 그때그때 계산.

### 빚 진행률
```
progress = (initialAmount - currentBalance) / initialAmount
```
`initialAmount` 없으면 `null`. UI에서 적절히 처리.

### 전체 진행률
```
totalInitial = sum of all debts' initialAmount
totalCurrent = sum of all debts' currentBalance
overallProgress = (totalInitial - totalCurrent) / totalInitial
```

### 우선순위 (Snowball)
빚을 `currentBalance` 오름차순으로 정렬. 가장 작은 빚이 우선.

### 우선순위 (Avalanche)
빚을 `interestRate` 내림차순으로 정렬. 가장 이자율 높은 빚이 우선.

### 예상 완납일
복리 기준 계산식:
```
M = 매달 상환액
P = 현재 잔액
r = 월 이자율 (연 이자율 / 12)

n = -log(1 - P*r/M) / log(1 + r)
```
`r = 0`이면: `n = P / M`

자세한 계산은 `core/utils/debt_calculator.dart`에 구현.

### 연속 기록 위험도
```
hoursLeft = 자정까지 남은 시간
streakAtRisk = hoursLeft <= 6 && 오늘 상환 기록 없음
```

## Hive 박스 구조

```dart
@HiveType(typeId: 0)
class UserBox { ... }

@HiveType(typeId: 1)
class DebtBox { ... }

@HiveType(typeId: 2)
class PaymentBox { ... }

@HiveType(typeId: 3)
class BadgeBox { ... }

@HiveType(typeId: 4)
class SettingsBox { ... }
```

박스 이름:
- `users`
- `debts`
- `payments`
- `badges`
- `settings`

## 마이그레이션 정책

- 스키마 변경 시 Hive `typeId` 절대 재사용 금지
- 필드 추가는 OK (기본값 제공)
- 필드 삭제는 deprecated 마킹 후 2버전 후 제거
- 큰 변경 시 마이그레이션 스크립트 작성

## Supabase 테이블 (Phase 3)

`posts`, `comments`, `likes`, `reports`, `community_users`

RLS (Row Level Security) 필수:
- 본인 글만 수정/삭제 가능
- 운영자만 `isPinned`, `isEditorPick` 수정 가능
- 익명 작성자 정보는 공개에 노출 안 됨
