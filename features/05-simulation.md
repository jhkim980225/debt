# Feature: Simulation

## 목적

사용자가 **얼마씩 갚으면 언제 끝나는지** 미리 보여줘서 더 큰 동기를 만들고, 두 가지 상환 전략 중 자기에게 맞는 것을 선택하게 함.

## 우선순위

**Phase 2 (동기부여 강화)**

MVP에는 빠져도 OK. 단, 빚 등록 화면의 "최소보다 더 갚으면 N개월 빨라져요" 기능은 Phase 1에 포함.

## 핵심 원칙

1. **두 전략 동시 비교**: 눈덩이 vs 눈사태 한눈에
2. **추천은 명확하게**: 사용자가 결정 못하게 둘 다 비슷하게 제시 X. "추천" 표시
3. **시각적 차이**: 그래프로 효과 즉각 인지

## 사용자 스토리

> 매달 얼마씩 갚을 수 있는지 입력하면, 어느 전략이 나에게 맞고 언제 끝나는지 한눈에 보고 결정하고 싶다.

## 진입 경로

1. **대시보드의 [시뮬레이션] 버튼**
2. **설정 > 상환 전략**

## 화면 구성

### 헤더
- 좌측: ← 뒤로
- 중앙: "상환 시뮬레이션"

### 섹션 1: 월 상환 가능 금액 입력
- 라벨: "월 상환 가능 금액"
- 큰 숫자 표시 (현재 값)
- **슬라이더**:
  - 최소: 200,000원
  - 최대: 2,000,000원
  - 단계: 50,000원
- 좌우 끝에 라벨: "20만원" / "200만원"
- 초기값: 사용자의 `monthlyBudget` (없으면 모든 빚의 최소 상환액 합계)

### 섹션 2: 전략 비교
- 헤드라인: "전략 비교"
- 카드 2개 (세로 스택)

#### 눈덩이 카드 (디폴트 추천)
- 강조 보더 (파란 톤)
- 헤더: "눈덩이 방식" + "추천" 배지
- 서브: "작은 빚부터 갚아 성취감 ↑"
- 그리드 2x1:
  - 좌측: "완납까지" + "X년 X개월"
  - 우측: "총 이자" + "X,XXX,XXX원"
- 탭으로 선택 가능

#### 눈사태 카드
- 일반 보더
- 헤더: "눈사태 방식"
- 서브: "고이자부터 갚아 총 이자 ↓"
- 그리드 2x1:
  - 좌측: "완납까지" + "X년 X개월"
  - 우측: "총 이자" + "X,XXX,XXX원" (녹색 강조 - 이게 더 적으면)

### 섹션 3: 잔액 변화 예측 (그래프)
- 헤드라인: "잔액 변화 예측"
- 라인 차트:
  - X축: 개월 (0 ~ 완납)
  - Y축: 잔액
  - 두 선:
    - 파란 실선: 눈덩이
    - 녹색 점선: 눈사태
  - 시작점 같음 (현재 총 잔액)
  - 종료점: 0
- 범례: "눈덩이" 파란선, "눈사태" 녹색선
- `fl_chart` 사용

### 섹션 4: 추가 인사이트 (선택)
선택한 전략에 따라:

- "이 페이스로 갚으면 **YYYY년 MM월**에 자유로워져요"
- "최소 결제만 하는 것보다 **N년 빨라져요**"
- "총 이자 **X원**을 절약해요"

### 하단 버튼
- **이 계획으로 시작하기** (메인)
  - 사용자의 전략 + 예산을 저장
  - 우선순위 재계산
  - 대시보드로 복귀

## 추천 로직

### 어떤 전략을 추천할까?

#### 눈덩이 추천 시
- 빚이 4개 이상
- 가장 작은 빚이 매우 작음 (전체의 10% 이하)
- 사용자 streak가 7일 미만 (초보자, 동기부여 우선)

#### 눈사태 추천 시
- 빚이 2-3개
- 이자율 차이가 큼 (5%p 이상)
- 사용자 streak가 30일 이상 (체화된 사용자)
- 총 이자 절약액이 큼 (50만원 이상 차이)

#### 디폴트
- 눈덩이 (심리적 부담 적음)

## 계산 로직

### 핵심 공식
복리 기준:
```
M = 매달 상환액
P = 원금 (잔액)
r = 월 이자율 = 연 이자율 / 12

n (개월) = -log(1 - P*r/M) / log(1 + r)
```

이자율이 0이면:
```
n = P / M
```

### 시뮬레이션 알고리즘

```
def simulate(debts, monthlyBudget, strategy):
    # 1. 빚 정렬
    if strategy == 'snowball':
        debts.sort(by=balance, asc)
    elif strategy == 'avalanche':
        debts.sort(by=interestRate, desc)

    months = 0
    totalInterest = 0
    history = []  # 월별 잔액 기록

    while sum(debt.balance for debt in debts) > 0:
        months += 1

        # 1. 모든 빚에 이자 부과
        for debt in debts:
            interest = debt.balance * (debt.interestRate / 100 / 12)
            debt.balance += interest
            totalInterest += interest

        # 2. 모든 빚에 최소 결제
        budgetLeft = monthlyBudget
        for debt in debts:
            payment = min(debt.minimumPayment or 0, debt.balance, budgetLeft)
            debt.balance -= payment
            budgetLeft -= payment

        # 3. 남은 예산을 우선순위 빚에 모두 (snowball/avalanche)
        if budgetLeft > 0:
            for debt in debts:
                if debt.balance > 0:
                    payment = min(debt.balance, budgetLeft)
                    debt.balance -= payment
                    budgetLeft -= payment
                    break  # 우선순위 1개에만

        history.append((months, sum(d.balance for d in debts)))

        if months > 600:  # 50년 안에 못 갚으면 무한루프 방지
            break

    return {
        'months': months,
        'totalInterest': totalInterest,
        'history': history,
    }
```

### 정확도 vs 성능
- 빚 10개 미만, 600개월 = 6000번 계산. 충분히 빠름
- 무거운 계산이라면 isolate 사용
- 결과는 메모이제이션 (입력 같으면 재계산 X)

## 인터랙션

### 슬라이더 조정
- 실시간으로 결과 갱신
- 디바운스 200ms (너무 잦은 계산 방지)

### 전략 카드 탭
- 선택 강조 변경
- 그래프 강조 변경

### "이 계획으로 시작하기"
- 사용자 설정 저장:
  - `user.strategy = 선택한 전략`
  - `user.monthlyBudget = 슬라이더 값`
- 우선순위 재계산 (모든 빚 대상)
- 대시보드로 복귀
- 토스트: "전략이 적용됐어요"

## Edge Cases

### 빚이 0개
- 이 화면 비활성. "갚을 빚이 없어요" 메시지

### 월 상환액이 최소 결제 합계보다 적음
- 경고: "이 금액으로는 최소 결제도 안 돼요"
- 슬라이더 최소값을 자동으로 그 값으로

### 이자율이 너무 높아 무한대로 늘어남
- 슬라이더 값으로는 갚을 수 없는 경우
- "이 페이스로는 빚이 줄지 않아요. 더 많이 갚거나 이자율 낮은 곳으로 옮겨야 해요"
- 600개월 (50년) 초과 시 표시

### 빚이 1개
- 두 전략 결과가 동일
- "빚이 1개라 두 전략의 차이가 없어요" 메시지
- 단순 시뮬레이션만 표시

### 사용자가 변경 직전 빠져나갔을 때
- 변경값 저장 안 함
- 다음에 들어오면 마지막 저장된 전략으로

## 카피 디테일

### 전략 설명
- **눈덩이**: "작은 빚부터 갚아 성취감 ↑"
  - 이유: 심리적 동기 우선
- **눈사태**: "고이자부터 갚아 총 이자 ↓"
  - 이유: 수학적 효율 우선

너무 길게 설명하지 않기. 사용자가 클릭하면 더 자세한 모달 (Phase 3).

## 분석 이벤트

- `simulation_viewed`
- `simulation_budget_changed` (oldValue, newValue)
- `simulation_strategy_changed` (strategy)
- `simulation_applied` (strategy, monthlyBudget)

## 관련 문서

- `02-debt-register.md` - 즉시 피드백 카드 (작은 시뮬)
- `03-dashboard.md` - 우선순위 빚 결정에 영향
- `09-settings.md` - 전략 변경

## 구현 체크리스트

### UI
- [ ] 슬라이더 (200K - 2M, step 50K)
- [ ] 전략 카드 2개 (눈덩이/눈사태)
- [ ] "추천" 배지 동적 결정
- [ ] 라인 차트 (`fl_chart`)
- [ ] 인사이트 카피
- [ ] 적용 버튼

### 계산 로직
- [ ] 복리 계산 함수 (`core/utils/debt_calculator.dart`)
- [ ] 시뮬레이션 알고리즘 (월별 시뮬)
- [ ] 메모이제이션
- [ ] 결과 비교 (이자, 기간)
- [ ] 추천 전략 결정

### 인터랙션
- [ ] 슬라이더 디바운스 (200ms)
- [ ] 전략 카드 탭
- [ ] 적용 시 user/debts 갱신

### Edge Cases
- [ ] 빚 0개 처리
- [ ] 너무 적은 예산 경고
- [ ] 무한대 케이스 안내
- [ ] 빚 1개일 때 단순 표시
