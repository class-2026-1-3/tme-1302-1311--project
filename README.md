# 🎡 낙동 랜드 (Nakdong Land)

> **주제:** 확률 게임 사이트 (***도박 아님!!!***)  
> **프로젝트명:** 낙동 랜드  
> **선정 이유:** 도파민이 부족해서 채울 곳이 필요했음

---

## 프로젝트 구조

```
project/
├── web/                          # 프론트엔드 (Nginx + HTML/CSS/JS)
│   ├── css/                      # 스타일시트
│   │   ├── charge.css
│   │   ├── login.css
│   │   └── mmain.css
│   ├── html/                     # HTML 페이지
│   │   ├── login.html            # 로그인 화면
│   │   ├── charge.html           # 충전소 화면
│   │   ├── mmain.html            # 메인 화면
│   │   ├── doback.html           # 벅샷 게임 화면
│   │   └── doback2.html          # 룰렛 게임 화면
│   ├── js/                       # JavaScript
│   │   └── doback2.js            # 룰렛 게임 로직
│   ├── public/                   # 정적 리소스 (이미지 등)
│   ├── nginx.conf                # Nginx 웹 서버 설정
│   ├── Dockerfile                # 웹 서버 Docker 이미지 빌드
│   └── .dockerignore
├── sql/                          # 데이터베이스 (MySQL)
│   ├── conf/
│   │   └── my.cnf                # MySQL 설정 파일
│   ├── init.sql                  # 테이블 생성 + 초기 데이터
│   └── dockerfile                # DB Docker 이미지 빌드
├── doback2.js                    # 룰렛 게임 JS (별도 배치)
├── docker-compose.yml            # 컨테이너 오케스트레이션
├── package.json                  # Bootstrap 의존성
├── package-lock.json
├── README.md
└── .gitignore
```

---

## 프로그램 주요 기능

1. **벅샷 게임** (`doback.html`) — 다양한 게임을 즐기고 코인을 획득
2. **룰렛 게임** (`doback2.html`) — 행운의 룰렛을 돌려 추가 코인 획득

---

## 실행 방법 (Docker)

```bash
docker compose up -d
```

- 웹 서버: `http://localhost:8080`
- MySQL: `localhost:3307` (root / root1234)

---

## 기여 방법

| 구성원 | 역할 |
|---|---|
| **권민세** (팀장) | 메인 · 충전소 · 로그인 화면 제작, DB 설계 |
| **방윤선** (팀원) | 벅샷 · 룰렛 게임 화면 제작, 화면 이동 기능 추가 |

---

## 어려웠던 점

파일을 클론받아서 같은 파일로 작업하지 않고 각각 다른 파일로 따로 작업을 해서 서로 연결이 되지 않아 고생했다. 🥲

---

## 웹 사이트 화면 구성

| 화면 | 설명 |
|---|---|
| 홈화면 | — |
| 로그인 화면 | `login.html` |
| 충전 화면 | `charge.html` |
| 메인 화면 | `mmain.html` |
| 게임 화면 | `doback.html` (벅샷), `doback2.html` (룰렛) |

---

## DB 테이블 구조

### 1. users — 회원 정보

| 컬럼명 | 설명 |
|---|---|
| user_id | 회원 번호 (PK) |
| user_name | 아이디 |
| password | 비밀번호 |
| coin | 보유 코인 |
| nickname | 화면 표시 닉네임 |
| created_at | 가입일 |

### 2. charge_history — 충전 기록

| 컬럼명 | 설명 |
|---|---|
| charge_id | 충전 번호 (PK) |
| user_id | 회원 번호 (FK) |
| amount | 충전 코인 |
| charge_date | 충전 일시 |
| pay_method | 결제 방식 |

### 3. game_history — 게임 결과

| 컬럼명 | 설명 |
|---|---|
| game_history_id | 게임 기록 고유 번호 (PK) |
| game_id | 게임 번호 |
| user_id | 회원 번호 (FK) |
| game_type | 게임 종류 |
| bet_coin | 베팅 코인 |
| result | 승/패 (WIN / LOSE) |
| created_at | 게임 일시 |

### 4. attendance — 출석 체크

| 컬럼명 | 설명 |
|---|---|
| attendance_id | 출석 번호 (PK) |
| user_id | 회원 번호 (FK) |
| attended_date | 출석 날짜 |

### 5. games — 게임 목록

| 컬럼명 | 설명 |
|---|---|
| game_id | 게임 번호 (PK) |
| game_name | 게임 이름 |
| description | 게임 설명 |
| image_url | 이미지 경로 |
| link_url | 링크 URL |