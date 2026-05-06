/// 앱 전체 문자열 상수 (나중에 i18n 키로 전환 가능)
class AppStrings {
  AppStrings._();

  // 앱 이름
  static const String appName = '빚프리';

  // 인증
  static const String signupTitle = '시작하기';
  static const String signupSubtitle = '3초만에 가입하고 빚 관리를 시작하세요';
  static const String loginTitle = '다시 만나서 반가워요';
  static const String loginSubtitle = '계속 이어서 갚아볼까요?';
  static const String or = '또는';
  static const String simpleLogin = '간편 로그인';
  static const String alreadyHaveAccount = '이미 계정이 있나요?';
  static const String login = '로그인';
  static const String noAccountYet = '아직 계정이 없나요?';
  static const String signup = '회원가입';
  static const String emailSignup = '이메일로 가입하기';
  static const String autoLogin = '자동 로그인';
  static const String forgotPassword = '비밀번호 찾기';

  // 소셜 로그인
  static const String kakaoLogin = '카카오로 시작하기';
  static const String googleLogin = 'Google로 시작하기';
  static const String appleLogin = 'Apple로 시작하기';
  static const String naverLogin = '네이버로 시작하기';

  // 비밀번호 찾기
  static const String passwordResetTitle = '비밀번호를 잊으셨나요?';
  static const String passwordResetSubtitle =
      '가입하신 이메일 주소를 입력해주세요. 인증 코드를 보내드릴게요.';
  static const String socialLoginGuide =
      '소셜 로그인(카카오, 구글 등)으로 가입하셨다면 해당 서비스에서 직접 로그인해주세요.';
  static const String getVerificationCode = '인증 코드 받기';
  static const String verificationCodeTitle = '인증 코드를 입력하세요';
  static const String newPasswordTitle = '새 비밀번호 설정';
  static const String newPasswordSubtitle = '8자 이상, 영문·숫자·특수문자 포함';
  static const String changePassword = '비밀번호 변경하기';
  static const String passwordChanged = '비밀번호가 변경됐어요';

  // 빚 등록
  static const String debtRegisterTitle = '새 빚 등록';
  static const String whatKindOfDebt = '어떤 빚인가요?';
  static const String selectCategory = '카테고리를 골라주세요';
  static const String debtName = '빚 이름';
  static const String currentBalance = '현재 남은 금액';
  static const String annualInterestRate = '연 이자율';
  static const String iDontKnow = '잘 모르겠어요';
  static const String dontWorryAboutAccuracy =
      '정확하지 않아도 괜찮아요. 나중에 언제든 수정할 수 있어요.';
  static const String nextStep = '다음 단계';
  static const String cancel = '취소';
  static const String skip = '건너뛰기';
  static const String registerComplete = '등록 완료';
  static const String repaymentPlan = '상환 계획을 세워볼까요?';
  static const String skipOk = '건너뛰어도 괜찮아요. 나중에 채울 수 있어요.';
  static const String minimumPayment = '매달 상환액';
  static const String targetPayment = '매달 목표 상환액';
  static const String paymentDay = '결제일';
  static const String notificationTiming = '언제 알려줄까요?';
  static const String previewCard = '이렇게 등록돼요';
  static const String loanTerm = '대출 기간';
  static const String estimatedGraduation = '예상 완납';

  // 등록 완료
  static const String firstStepTaken = '첫 걸음을 떼셨어요!';
  static const String firstStepMessage =
      '빚을 정확히 마주하는 게 가장 어려운 일이에요. 이미 큰 산을 넘었어요.';
  static const String newBadgeEarned = '새 배지 획득';
  static const String firstStepBadge = '첫 걸음';
  static const String addAnotherDebt = '다른 빚도 등록하기';
  static const String addAnotherDebtReason =
      '전체 그림이 보여야 계획이 정확해져요';
  static const String goToDashboard = '대시보드로 가기';
  static const String goToDashboardReason = '전체 진행 상황을 한눈에';

  // 대시보드
  static const String hello = '안녕하세요';
  static const String totalDebt = '남은 총 빚';
  static const String overallProgress = '전체 진행률';
  static const String myDebts = '내 빚 목록';
  static const String priority = '우선순위';
  static const String recordPayment = '상환 기록';
  static const String simulation = '시뮬레이션';
  static const String registerFirstDebt = '첫 빚을 등록해볼까요?';
  static const String registerFirstDebtSub = '정확히 마주하면 갚는 길이 보여요';

  // 상환 기록
  static const String paymentRecordTitle = '상환 기록';
  static const String whereDidYouPay = '어디에 갚았어요?';
  static const String howMuchDidYouPay = '얼마 갚았어요?';
  static const String thisIsHowItChanges = '이렇게 바뀌어요';
  static const String remainingBalance = '남은 잔액';
  static const String progressRate = '진행률';
  static const String whenDidYouPay = '언제 갚았어요?';
  static const String today = '오늘';
  static const String yesterday = '어제';
  static const String selectDate = '날짜 선택';
  static const String recordComplete = '기록 완료';

  // 처음 빌린 금액
  static const String initialAmount = '처음 빌린 금액';
  static const String initialAmountSub = '비워두면 남은 금액과 동일하게 설정돼요';
  static const String errorInitialLessThanBalance = '처음 빌린 금액은 남은 금액 이상이어야 해요';

  // 에러 메시지
  static const String errorEmailOrPassword = '이메일 또는 비밀번호를 확인해주세요';
  static const String errorDuplicateEmail = '이미 가입된 이메일이에요. 로그인해주세요';
  static const String errorNetwork = '인터넷 연결을 확인해주세요';
  static const String errorTryLater = '잠시 후 다시 시도해주세요';
  static const String errorCodeExpired = '코드가 만료됐어요. 다시 받아주세요';
  static const String errorCodeMismatch = '코드가 일치하지 않아요';
  static const String errorSelectCategory = '카테고리를 선택해주세요';
  static const String errorEnterDebtName = '빚 이름을 입력해주세요';
  static const String errorEnterBalance = '남은 금액을 입력해주세요';
  static const String errorMinAmount = '1원 이상 입력해주세요';

  // 하단 탭
  static const String tabHome = '홈';
  static const String tabStats = '기록';
  static const String tabBadges = '배지';
  static const String tabCommunity = '함께';

  // 원 단위
  static const String won = '원';
  static const String percent = '%';

  // 알림 시점
  static const String threeDaysBefore = '결제일 3일 전';
  static const String threeBeforeSub = '미리 준비할 시간이 있어요';
  static const String sameDay = '결제일 당일';
  static const String noNotification = '알림 안 받기';
}
