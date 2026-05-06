# Feature: Badges & Motivation

## 목적

빚 상환 같은 장기 목표는 매일 동기 잃기 쉬움. **작은 성취를 시각화**해서 게이미피케이션으로 리텐션 유지.

## 우선순위

**Phase 2**

단, **연속 기록(streak)** 은 Phase 1에 포함 (대시보드에 표시).

## 핵심 원칙

1. **잠긴 배지를 보여줘서 호기심 유발**: "다음에 뭘 따지?"
2. **비교 X**: 다른 사용자랑 비교하지 않음. 본인 여정만
3. **부정적 트리거 X**: "X 못 했어요" 같은 거 X. "다시 시작해요" O
4. **경고는 부드럽게**: 연속 기록 끊기기 직전 알림은 위협적이면 안 됨

## 사용자 스토리

> 매일 작은 진전이 모여 큰 변화를 만들고 있다는 것을 시각적으로 느끼고, 다음 목표를 향해 나아가고 싶다.

## 진입 경로

- 하단 탭바의 "배지" 탭

## 화면 구성: 나의 여정

### 헤더
- "나의 여정"

### 섹션 1: 연속 기록 (Streak)
- 큰 원형 카드 (가운데 정렬)
- 안에 큰 숫자: 현재 연속 일수
- 아래: "X일 연속 상환 중"
- 더 작게: "최고 기록까지 X일 남았어요" 또는 "최고 기록 갱신 중!"

#### 7일 캘린더 시각화
- 이번 주 7일 (월~일)
- 각 날에 색칠 (갚은 날) / 비어있음 (안 갚은 날)
- 오늘은 굵게

### 섹션 2: 획득한 배지
- 헤더: "획득한 배지" + 우측 "X / 18"
- 그리드 3x6 (총 18개)
- 각 셀:
  - 원형 아이콘 (배지 시각화)
  - 배지 이름
  - 작은 설명
- 잠긴 배지: 회색 톤 + "?" 마크 + "잠금 해제 필요"

### 섹션 3: 오늘의 한마디
- 보라 톤 카드
- 헤드라인: "오늘의 한마디"
- 시리프 폰트 인용구
- 매일 다름

## 배지 시스템

### 배지 종류 (18개)

`docs/data-model.md`의 Badge 표 참조. 각 배지의 트리거 조건:

| ID | 이름 | 트리거 |
|----|------|--------|
| `firstStep` | 첫 걸음 | 첫 Payment 생성 |
| `sevenDayStreak` | 7일 연속 | streak >= 7 |
| `thirtyDayStreak` | 30일 연속 | streak >= 30 |
| `hundredDayStreak` | 100일 연속 | streak >= 100 |
| `tenPercentClear` | 10% 클리어 | overallProgress >= 0.1 |
| `quarterClear` | 25% 클리어 | overallProgress >= 0.25 |
| `halfClear` | 50% 클리어 | overallProgress >= 0.5 |
| `million` | 100만원 | sum(Payment.amount) >= 1,000,000 |
| `fiveMillion` | 500만원 | sum(Payment.amount) >= 5,000,000 |
| `tenMillion` | 1000만원 | sum(Payment.amount) >= 10,000,000 |
| `interestSaver` | 이자 절약가 | 절약 이자 >= 100,000 |
| `firstGraduation` | 첫 졸업 | 첫 Debt isPaidOff 변경 |
| `allCleared` | 자유 | 모든 Debt isPaidOff |
| `comeback` | 컴백 | streak 0 → 1 (이전 streak >= 7 이후) |
| `extraEffort` | 한 걸음 더 | isExtra 플래그 5회 |
| `disciplined` | 꾸준함 | 30일간 매일 정확히 targetPayment |
| `earlyBird` | 일찍 일어나는 새 | 결제일 3일 이전 갚기 5회 |
| `weekendWarrior` | 주말 전사 | 주말 (토/일) Payment 5회 |

### 트리거 시점

각 트리거는 **Payment 생성 후** 자동 체크:

```dart
// 의사 코드
void onPaymentCreated(Payment p) {
  final user = getUser();
  final allDebts = getDebts();
  final allPayments = getPayments();

  // 배지 체크
  for (badgeId in badgeIds) {
    if (!user.hasBadge(badgeId) && checkCondition(badgeId, ...)) {
      awardBadge(badgeId);
    }
  }
}
```

### 배지 획득 시 UX

#### 즉시 (상환 기록 직후)
- 모달 또는 다이얼로그
- 별 효과 + 배지 이미지 등장 애니메이션
- "새 배지: {배지이름}" 헤드라인
- "{설명}" 서브
- "확인" 버튼

#### 지연 (다음 진입 시)
- 사용자가 모달 닫고 닫기로 한 경우
- 배지 화면 진입 시 "획득" 마크 강조

#### 한 번만
- 같은 배지 두 번 획득 안 됨
- `Badge` 엔티티의 `earnedAt`이 있으면 이미 획득

## 연속 기록 (Streak)

### 핵심 로직

**streak = 끊김 없이 매일 Payment 1건 이상 한 일수**

#### 갱신 조건
```dart
void onPaymentCreated(Payment p) {
  final today = today();
  final yesterday = today - 1day;
  final user = getUser();

  // 오늘 첫 기록인가?
  if (!hasPaymentOn(today)) {  // 이미 오늘 기록 있으면 streak 변동 X
    if (hasPaymentOn(yesterday)) {
      // 어제도 있음 → 연속 유지
      user.streak += 1;
    } else {
      // 어제 없음 → 리셋
      user.streak = 1;
    }
  }

  user.longestStreak = max(user.longestStreak, user.streak);
}
```

#### 자정 체크 (옵션)
- 매일 자정에 백그라운드 체크
- 어제도 안 갚고 오늘도 안 갚으면 → streak = 0
- 푸시: "오늘 갚지 않으면 연속 기록이 끊겨요"

### 위험 상태 (Streak at Risk)

오늘 기록 없고 자정까지 6시간 이내일 때:
- 푸시 알림 발송 (사용자 설정 시)
- 대시보드 연속 기록 카드 색 변경 (경고)
- 카피: "오늘이 가기 전에 한 번 기록해볼까요?"

### 끊김 처리

streak 0이 됐을 때:
- 비난 X. 다시 시작 응원 ✓
- "연속 기록이 리셋됐어요. 오늘부터 다시 시작!"
- 7일 이상 streak였다가 끊긴 후 다시 시작 → `comeback` 배지

## 동기부여 메시지 시스템

### 메시지 풀

#### 일반 (50개+)
- "오늘도 한 걸음씩, 천천히 가요"
- "꾸준함이 답이에요"
- "어제보다 가까워지고 있어요"
- 등

#### 상황별 메시지

##### Streak 기반
- streak == 1: "첫 걸음 떼셨어요!"
- streak == 7: "일주일 동안 멈추지 않았어요"
- streak >= 30: "한 달 동안 매일! 진짜 꾸준해요"
- streak == 0 (어제 끊김): "다시 시작하는 게 가장 중요해요"

##### 진행률 기반
- progress < 0.1: "시작이 반이에요"
- progress >= 0.5: "절반을 넘었어요. 정말 멋져요"
- progress >= 0.9: "거의 다 왔어요!"

##### 시간 기반
- 새 달 첫날: "5월의 첫 걸음을 떼볼까요?"
- 월말 (25일 이후): "이번 달도 마무리해볼까요?"
- 결제일 임박: "신용카드 A 결제일이 3일 남았어요"

##### 빚 기반
- 빚 졸업 직후: "{빚이름} 졸업! 다음 목표로!"
- 큰 빚 갚는 중: "이 큰 산만 넘으면 자유에요"

### 메시지 선택 알고리즘

```dart
String selectMotivationMessage(User user, List<Debt> debts) {
  // 1. 특별 상황 우선
  if (user.streak == 0 && previousStreak >= 7) {
    return "다시 시작하는 게 가장 중요해요";
  }

  // 2. 마일스톤 임박
  if (overallProgress > 0.45 && overallProgress < 0.5) {
    return "거의 절반이에요";
  }

  // 3. 임박한 결제일
  final upcomingDebt = findClosestPaymentDay(debts);
  if (upcomingDebt && daysUntil <= 3) {
    return "{name} 결제일이 {N}일 남았어요";
  }

  // 4. Streak 강조
  if (user.streak >= 7) {
    return "{N}일째 멈추지 않고 있어요";
  }

  // 5. 일반 풀에서 랜덤 (하루마다 일정)
  return generalPool[hashOfDate(today) % generalPool.length];
}
```

## 인용구 시스템 (Daily Quote)

### 풀 (30개+)
시리프 폰트로 표시되는 짧은 격언:
- "빚을 갚는 건 미래의 나에게 보내는 선물이에요."
- "한 걸음 한 걸음, 자유에 가까워지고 있어요."
- "오늘의 절약이 내일의 자유를 만들어요."

### 표시 규칙
- 매일 자정 기준으로 새로운 인용구
- 같은 날 여러 번 봐도 같음 (일관성)
- 사용자 ID + 날짜를 해시로 결정

## 카피 디테일

### 배지 이름 규칙
- 짧고 시각적 (`docs/glossary.md` 참조)
- 비교형 X: "최고", "1등"
- 부정형 X: "포기 안 함"
- 긍정/중립 O: "꾸준함", "한 걸음 더"

### 동기부여 톤
- 친구 톤 (`docs/glossary.md` 알림 메시지 톤 참조)
- 명령형 X
- 권유형 O

## Edge Cases

### 시간대 변경
- 사용자가 해외 여행 등으로 시간대 변경
- 디바이스 시간대 기준으로 streak 계산
- 변경 후 streak 깨질 수 있음 (수용)

### 한 번에 여러 배지 획득
- 한 Payment로 2개 이상 트리거 가능 (예: 첫 걸음 + 100만원 동시)
- 다이얼로그를 순차 표시 (애니메이션 끊지 않게)

### 잠긴 배지 정보 노출
- 사용자가 어떻게 따는지 궁금해함
- 잠금 카드 탭 시 힌트 표시:
  - "10일 연속 상환하면 획득"
- 단, 너무 자세히 X (모든 정보 노출 X)

### 배지 마이그레이션
- 새 배지 추가 시 기존 사용자에게 소급 적용
- 조건 만족하는 사용자는 다음 진입 시 자동 획득

### 데이터 손실
- 클라우드 동기화 안 한 사용자가 기기 변경
- 배지 모두 잃을 수 있음 (Phase 1 한계)
- 클라우드 동기화 권장 (Phase 3)

## 분석 이벤트

- `badges_screen_viewed`
- `badge_earned` (badgeId, totalEarned)
- `streak_updated` (oldValue, newValue)
- `streak_broken` (previousStreak)
- `streak_milestone` (days: 7/30/100)
- `motivation_message_shown` (messageId)

## 알림 (관련)

| 종류 | 시점 | 내용 |
|------|------|------|
| Streak 위험 | 밤 9시, 오늘 기록 없음 | "오늘이 가기 전에 한 번 기록해볼까요?" |
| 배지 획득 | 즉시 (상환 기록 후) | 인앱 다이얼로그 |
| 마일스톤 임박 | 자동 | "오늘 갚으면 100일 연속이에요!" |

## 관련 문서

- `04-payment-record.md` - 배지 트리거 시점
- `03-dashboard.md` - streak 카드 표시
- `docs/data-model.md` - Badge 엔티티
- `docs/glossary.md` - 배지 이름 규칙

## 구현 체크리스트

### UI
- [ ] 연속 기록 큰 카드 (원형)
- [ ] 7일 캘린더 시각화
- [ ] 배지 그리드 3x6 (18개)
- [ ] 잠긴 배지 디자인
- [ ] 오늘의 한마디 카드

### 로직
- [ ] streak 계산 (자정 기준)
- [ ] 자정 백그라운드 체크
- [ ] 배지 트리거 함수 (18개)
- [ ] 동기부여 메시지 선택 알고리즘
- [ ] 일일 인용구 (해시 기반)

### 인터랙션
- [ ] 배지 획득 다이얼로그 (상환 기록 후)
- [ ] 잠긴 배지 탭 → 힌트
- [ ] 다중 배지 순차 표시

### 알림
- [ ] Streak 위험 푸시
- [ ] 마일스톤 임박 푸시

### 데이터
- [ ] Badge 엔티티 저장
- [ ] User streak 필드 갱신
- [ ] 배지 마이그레이션 처리
