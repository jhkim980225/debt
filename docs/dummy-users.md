# 더미 사용자 (테스트용)

이 문서에 기재된 더미 데이터는 **테스트 전용**입니다.
프로덕션 배포 전 아래 파일에서 관련 코드를 삭제하세요.

## 관련 파일

| 파일 | 내용 | 삭제 방법 |
|------|------|-----------|
| `test/community_test.dart` | 더미 사용자/게시글/댓글 + 테스트 | 파일 삭제 또는 더미 데이터 함수 제거 |
| `lib/features/community/data/community_providers.dart` | `seedPosts()`, `seedComments()` 메서드 | 두 seed 메서드 제거 |

## 더미 사용자 10명

| ID | 닉네임 | 게시글 | 카테고리 |
|----|--------|--------|----------|
| `user-001` | 햇살모은이 | 드디어 빚 갚기 시작했어요 | 자유 |
| `user-002` | 조용한걸음 | 커피값 아끼니까 한 달에 15만원 절약됨 | 절약 (HOT) |
| `user-003` | 바람부는언덕 | 학자금 대출 이자율 낮추는 방법 있나요? | 질문 |
| `user-004` | 꾸준한하루 | 100일 연속 상환 달성! | 인증 (HOT) |
| `user-005` | 새벽이슬 | 리볼빙의 늪에서 빠져나온 이야기 | 공포의빚 (익명) |
| `user-006` | 산책하는고양이 | 주말 배달 알바로 월 80만원 추가 수입 | 부업 |
| `user-007` | 느린거북이 | 신용점수 올리는 현실적인 방법 정리 | 금융정보 (HOT, 에디터픽) |
| `user-008` | 달빛여행자 | 오늘 마지막 할부금 냈어요 | 자유 (HOT) |
| `user-009` | 푸른나무 | 눈덩이 방식이 정말 효과 있나요? | 질문 |
| `user-010` | 작은불꽃 | 첫 빚 졸업! 카드빚 200만원 완납 | 인증 |

## 더미 댓글 14개

| ID | 게시글 | 작성자 | 대댓글 여부 |
|----|--------|--------|-------------|
| `comment-001` | post-001 | 조용한걸음 | - |
| `comment-002` | post-001 | 꾸준한하루 | - |
| `comment-003` | post-001 | 햇살모은이 | comment-001에 대한 답글 |
| `comment-004` | post-002 | 바람부는언덕 | - |
| `comment-005` | post-002 | 산책하는고양이 | - |
| `comment-006` | post-002 | 푸른나무 | - (익명) |
| `comment-007` | post-002 | 조용한걸음 | comment-004에 대한 답글 |
| `comment-008` | post-004 | 달빛여행자 | - |
| `comment-009` | post-004 | 작은불꽃 | - |
| `comment-010` | post-004 | 꾸준한하루 | comment-008에 대한 답글 |
| `comment-011` | post-005 | 느린거북이 | - |
| `comment-012` | post-009 | 느린거북이 | - |
| `comment-013` | post-009 | 꾸준한하루 | - |
| `comment-014` | post-009 | 푸른나무 | comment-012에 대한 답글 |

## 삭제 체크리스트

- [ ] `test/community_test.dart`에서 `_dummyUsers`, `_createDummyPosts()`, `_createDummyComments()` 제거
- [ ] `lib/features/community/data/community_providers.dart`에서 `seedPosts()`, `seedComments()` 제거
- [ ] 이 문서 (`docs/dummy-users.md`) 삭제
