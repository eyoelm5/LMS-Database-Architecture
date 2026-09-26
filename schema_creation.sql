/* * NOTE: Most tables in this file are created using the STRICT table feature in SQLITE 
 * and uses types names such as TEXT which are exclusive to SQLITE.
 * Therefore please ensure to use this Data Definition Language commands only on SQLITE.
*/


/* ---------- USER ACCOUNT MANAGEMENT ----------- */

/* Users and their personal informations */
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    type_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp
) STRICT;

CREATE TABLE profiles (
    user_id INTEGER PRIMARY KEY,
    first_name TEXT  NOT NULL,
    middle_initial TEXT,
    last_name TEXT NOT NULL,
    date_of_birth TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_user_profile FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE 
) STRICT;

CREATE TABLE emergency_contacts (
    contact_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    first_name TEXT  NOT NULL,
    last_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    relationship TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_profile_emergency_contacts FOREIGN KEY (user_id) REFERENCES profiles(user_id) ON DELETE CASCADE
) STRICT;

/* Role Based Access Control (RBAC) */
CREATE TABLE roles (
    role_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp
) STRICT;

CREATE TABLE permissions(
    permission_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp
) STRICT;

CREATE TABLE role_permission(
    role_id INTEGER,
    permission_id INTEGER,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_role_permission PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_role_permission_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    CONSTRAINT fk_role_permission_permission FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE
) STRICT, WITHOUT ROWID;

Create INDEX idx_user_role ON users(role_id);

/* User Type - Specialisations */
CREATE TABLE user_types (
    type_id INTEGER PRIMARY KEY, 
    name TEXT UNIQUE NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp
) STRICT;

CREATE TABLE employees (
    user_id INTEGER PRIMARY KEY,
    global_personnel_id TEXT UNIQUE NOT NULL,
    yearly_salary REAL NOT NULL,
    start_date TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_employee_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) STRICT, WITHOUT ROWID;

CREATE TABLE students (
    user_id INTEGER PRIMARY KEY,
    student_id TEXT UNIQUE NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) STRICT, WITHOUT ROWID;

CREATE INDEX idx_user_type ON users(type_id);

/* Role and User type constraint for user table */
PRAGMA foreign_keys = 0;

DROP TABLE users;

CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    type_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT user_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE RESTRICT,
    CONSTRAINT user_type FOREIGN KEY (type_id) REFERENCES user_types(type_id) ON DELETE RESTRICT
) STRICT;

CREATE INDEX idx_user_role ON users (role_id);
CREATE INDEX idx_user_type ON users (type_id);

PRAGMA foreign_keys = 1;

/* Businesses and their students*/
CREATE TABLE businesses (
    business_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    company_name TEXT UNIQUE NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_business_manager FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) STRICT;

CREATE TABLE business_student(
    user_id INTEGER PRIMARY KEY,
    business_id INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_business_students_student FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_business_students_business FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE RESTRICT
) STRICT, WITHOUT ROWID;

CREATE INDEX idx_business ON business_student (business_id);


/* ---------- Address MANAGEMENT ----------- */

CREATE TABLE countries(
    country_id INTEGER PRIMARY KEY,
    country_code TEXT UNIQUE NOT NULL,
    name TEXT UNIQUE NOT NULL,
    currency_code TEXT NOT NULL,
    dial_code TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp
) STRICT;

CREATE TABLE addresses (
    address_id INTEGER PRIMARY KEY,
    country_id INTEGER NOT NULL,
    address_line_1 TEXT NOT NULL,
    address_line_2 TEXT,
    address_line_3 TEXT,
    province TEXT,
    city TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_address_country FOREIGN KEY (country_id) REFERENCES countries(country_id) ON DELETE RESTRICT
) STRICT;

CREATE INDEX idx_city ON addresses(city);

CREATE TABLE address_types(
    address_type_id INTEGER PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp
) STRICT;

CREATE TABLE user_addresses (
    address_type_id INTEGER,
    address_id INTEGER NOT NULL,
    user_id INTEGER,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_user_address PRIMARY KEY (user_id, address_type_id),
    CONSTRAINT u_address_type_address UNIQUE (address_type_id, address_id),
    CONSTRAINT fk_user_addresses_address_type FOREIGN KEY (address_type_id) REFERENCES address_types(address_type_id) ON DELETE RESTRICT,
    CONSTRAINT fk_user_addresses_address FOREIGN KEY (address_id) REFERENCES addresses(address_id) ON DELETE RESTRICT,
    CONSTRAINT fk_user_addresses_user FOREIGN KEY (user_id) REFERENCES profiles(user_id) ON DELETE CASCADE
) STRICT;

CREATE INDEX idx_address_id ON user_addresses(address_id);

CREATE TABLE business_addresses (
    address_type_id INTEGER,
    address_id INTEGER NOT NULL,
    business_id INTEGER,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_business_address PRIMARY KEY (business_id, address_type_id),
    CONSTRAINT u_address_type_address UNIQUE (address_type_id, address_id),
    CONSTRAINT fk_user_addresses_address_type FOREIGN KEY (address_type_id) REFERENCES address_types(address_type_id) ON DELETE RESTRICT,
    CONSTRAINT fk_user_addresses_address FOREIGN KEY (address_id) REFERENCES addresses(address_id) ON DELETE RESTRICT,
    CONSTRAINT fk_user_addresses_business FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE
) STRICT;

/* ---------- Course MANAGEMENT ----------- */

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT UNIQUE NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp
) STRICT;

CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL,
    course_code TEXT UNIQUE NOT NULL,
    course_name TEXT NOT NULL,
    description TEXT NOT NULL,
    total_hours INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_course_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE prerequisite_topics (
    course_id INTEGER,
    topic_name TEXT,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_prerequisite_topics PRIMARY KEY (course_id, topic_name),
    CONSTRAINT fk_prerequisite_topic_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
) STRICT, WITHOUT ROWID;

CREATE TABLE certificates (
    certificate_id INTEGER PRIMARY KEY, 
    course_id INTEGER NOT NULL,
    certificate_name TEXT NOT NULL,
    template_path TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_certificate_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
) STRICT;

CREATE TABLE student_certificate(
    user_id INTEGER,
    certificate_id INTEGER,
    date TEXT NOT NULL,
    certificate_path TEXT NOT NULL, 
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_student_certificate PRIMARY KEY (user_id, certificate_id),
    CONSTRAINT fk_student_certificate_student FOREIGN KEY (user_id) REFERENCES students(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_student_certificate_certificate FOREIGN KEY (certificate_id) REFERENCES certificates(certificate_id) ON DELETE RESTRICT
) STRICT;


/* ---------- COURSE DELIVERY ----------- */

CREATE TABLE sessions (
    session_id INTEGER PRIMARY KEY,
    year INTEGER UNIQUE NOT NULL CHECK (year > 2000),
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp
) STRICT;

CREATE TABLE terms (
    term_id INTEGER PRIMARY KEY,
    session_id INTEGER NOT NULL,
    term_name TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT u_session_term UNIQUE (session_id, term_name),
    CONSTRAINT fk_term_session FOREIGN KEY (session_id) REFERENCES sessions(session_id) ON DELETE CASCADE
) STRICT;

CREATE TABLE campuses (
    campus_id INTEGER PRIMARY KEY,
    address_id INTEGER UNIQUE NOT NULL,
    campus_code TEXT UNIQUE NOT NULL,
    campus_name TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_campus_address FOREIGN KEY (address_id) REFERENCES addresses(address_id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE buildings (
    building_id INTEGER PRIMARY KEY,
    address_id INTEGER UNIQUE NOT NULL,
    campus_id INTEGER NOT NULL,
    building_name TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_building_address FOREIGN KEY (address_id) REFERENCES addresses(address_id) ON DELETE RESTRICT,
    CONSTRAINT fk_building_campus FOREIGN KEY (campus_id) REFERENCES campuses(campus_id) ON DELETE CASCADE
) STRICT;

CREATE TABLE rooms(
    room_id INTEGER PRIMARY KEY,
    building_id INTEGER NOT NULL,
    room_number TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT u_building_room_number UNIQUE (building_id, room_number),
    CONSTRAINT fk_room_building FOREIGN KEY (building_id) REFERENCES buildings(building_id) ON DELETE CASCADE
) STRICT;


/* ---------- COURSE MANAGEMENT & DELIVERY ----------- */

CREATE TABLE course_term_campus (
    course_term_id INTEGER PRIMARY KEY,
    campus_id INTEGER NOT NULL,
    term_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    course_fee INTEGER NOT NULL,
    capacity INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT u_campus_term_course UNIQUE (course_id, term_id, campus_id),
    CONSTRAINT fk_course_term_campus_campus FOREIGN KEY (campus_id) REFERENCES campuses(campus_id) ON DELETE CASCADE,
    CONSTRAINT fk_course_term_campus_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    CONSTRAINT fk_course_term_campus_term FOREIGN KEY (term_id) REFERENCES terms(term_id) ON DELETE CASCADE
) STRICT;

CREATE INDEX idx_ctc_campus ON course_term_campus(campus_id);
CREATE INDEX idx_ctc_term ON course_term_campus(term_id);

CREATE TABLE course_term_teacher (
    user_id INTEGER, 
    course_term_id INTEGER,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_teacher_course_term PRIMARY KEY (user_id, course_term_id),
    CONSTRAINT fk_course_term_teacher_employee FOREIGN KEY (user_id) REFERENCES employees(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_course_term_teacher_course_term FOREIGN KEY (course_term_id) REFERENCES course_term_campus(course_term_id) ON DELETE RESTRICT
) STRICT, WITHOUT ROWID;

CREATE INDEX idx_ctt_course_term ON course_term_teacher(course_term_id);

CREATE TABLE course_term_support(
    user_id_e INTEGER NOT NULL, 
    user_id_s INTEGER,
    course_term_id INTEGER,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_student_course_term PRIMARY KEY (user_id_s, course_term_id),
    CONSTRAINT fk_course_term_support_employee FOREIGN KEY (user_id_e) REFERENCES employees(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_course_term_support_course_term FOREIGN KEY (course_term_id) REFERENCES course_term_campus(course_term_id) ON DELETE RESTRICT,
    CONSTRAINT fk_course_term_support_student FOREIGN KEY (user_id_s) REFERENCES students(user_id) ON DELETE RESTRICT
) STRICT, WITHOUT ROWID;

CREATE TABLE course_term_students (
    user_id INTEGER, 
    course_term_id INTEGER,
    results TEXT CHECK (results IN ('pass','fail')),
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_user_course_term PRIMARY KEY (user_id, course_term_id),
    CONSTRAINT fk_course_term_student_student FOREIGN KEY (user_id) REFERENCES students(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_course_term_teacher_student_term FOREIGN KEY (course_term_id) REFERENCES course_term_campus(course_term_id) ON DELETE RESTRICT
) STRICT, WITHOUT ROWID;

CREATE TABLE lectures (
    lecture_id INTEGER PRIMARY KEY, 
    course_term_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    room_id INTEGER NOT NULL,
    date TEXT NOT NULL,
    start_time TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_lecture_employee FOREIGN KEY (user_id) REFERENCES employees(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lecture_course_term FOREIGN KEY (course_term_id) REFERENCES course_term_campus(course_term_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lecture_room FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE lecture_students (
    user_id INTEGER, 
    lecture_id INTEGER,
    status TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_user_lecture PRIMARY KEY (user_id, lecture_id),
    CONSTRAINT fk_lecture_student_student FOREIGN KEY (user_id) REFERENCES students(user_id) ON DELETE  RESTRICT,
    CONSTRAINT fk_lecture_student_lecture FOREIGN KEY (lecture_id) REFERENCES lectures(lecture_id) ON DELETE RESTRICT
) STRICT, WITHOUT ROWID;


/* ---------- Finance Management ----------- */

CREATE TABLE payment_plan (
    plan_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    no_installments INTEGER NOT NULL,
    interval_months INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp
) STRICT;

CREATE TABLE fees (
    fee_id INTEGER PRIMARY KEY,
    plan_id INTEGER NOT NULL,
    total_amount REAL NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending','partially_paid','paid', 'cancelled')),
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_fee_plan FOREIGN KEY (plan_id) REFERENCES payment_plan(plan_id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE installments (
    installment_id INTEGER PRIMARY KEY,
    fee_id INTEGER NOT NULL,
    installment_no INTEGER NOT NULL,
    amount_due REAL NOT NULL,
    due_date TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending','paid', 'cancelled')),
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_installments_fee FOREIGN KEY (fee_id) REFERENCES fees(fee_id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    installment_id INTEGER NOT NULL,
    transaction_id TEXT UNIQUE NOT NULL,
    amount REAL NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'failed')),
    payment_timestamp TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_payment_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_installment FOREIGN KEY (installment_id) REFERENCES installments(installment_id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE business_fee (
    fee_id INTEGER PRIMARY KEY,
    business_id INTEGER NOT NULL,
    no_students INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_business_fee_fee FOREIGN KEY (fee_id) REFERENCES fees(fee_id) ON DELETE CASCADE,
    CONSTRAINT fk_business_fee_business FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE
) STRICT, WITHOUT ROWID;

CREATE TABLE student_fee (
    fee_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT fk_student_fee_student FOREIGN KEY (user_id) REFERENCES students(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_student_fee_fee FOREIGN KEY (fee_id) REFERENCES fees(fee_id) ON DELETE CASCADE
) STRICT, WITHOUT ROWID;

CREATE TABLE course_term_fee (
    course_term_id INTEGER,
    fee_id INTEGER,
    created_at TEXT NOT NULL DEFAULT current_timestamp,
    updated_at TEXT NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_course_term_fee PRIMARY KEY (fee_id, course_term_id),
    CONSTRAINT fk_course_term_fee_course_term FOREIGN KEY (course_term_id) REFERENCES course_term_campus(course_term_id) ON DELETE RESTRICT,
    CONSTRAINT fk_course_term_fee FOREIGN KEY (fee_id) REFERENCES fees(fee_id) ON DELETE CASCADE
) STRICT, WITHOUT ROWID;



/* --------- Triggers ----------- */
CREATE TRIGGER trg_prevent_concurrent_enrollment
BEFORE INSERT ON course_term_students
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 
            FROM course_term_students 
            WHERE user_id = NEW.user_id 
              AND start_date <= NEW.end_date 
              AND end_date >= NEW.start_date
        )
        THEN RAISE(ABORT, 'Cannot enroll: Student is already enrolled in a course during this time period.')
    END;
END;


CREATE TRIGGER trg_prevent_over_enrollment
BEFORE INSERT ON course_term_students
BEGIN
    SELECT CASE 
        WHEN (
            SELECT COUNT(*) 
            FROM course_term_students 
            WHERE course_term_id = NEW.course_term_id
        ) >= (
            SELECT capacity 
            FROM course_term_campus 
            WHERE course_term_id = NEW.course_term_id
        )
        THEN RAISE(ABORT, 'Cannot enroll: Course capacity has been reached.')
    END;
END;

CREATE TRIGGER trg_check_certificate_eligibility
BEFORE INSERT ON student_certificate
BEGIN
    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1 
            FROM course_term_students cts
            JOIN course_term_campus ctc ON cts.course_term_id = ctc.course_term_id
            WHERE cts.user_id = NEW.user_id 
              AND ctc.course_id = (SELECT course_id FROM certificates WHERE certificate_id = NEW.certificate_id)
              AND cts.results = 'pass'
        )
        THEN RAISE(ABORT, 'Cannot issue certificate: Student has not passed this course.')
    END;
END;

/* -------- Views ---------- */
CREATE VIEW vw_course_term_details AS
SELECT 
    ctc.course_term_id,
    c.campus_code,
    co.course_code,
    s.year,
    t.term_name,
    t.start_date,
    t.end_date,
    ctc.course_fee,
    ctc.capacity
FROM course_term_campus ctc
JOIN campuses c ON ctc.campus_id = c.campus_id
JOIN courses co ON ctc.course_id = co.course_id
JOIN terms t ON ctc.term_id = t.term_id
JOIN sessions s ON t.session_id = s.session_id;

CREATE VIEW vw_user_directory AS
SELECT 
    u.user_id,
    p.first_name,
    p.last_name,
    u.email,
    p.phone_number,
    ut.name AS user_type,
    r.name AS role_name
FROM users u
JOIN profiles p ON u.user_id = p.user_id
JOIN user_types ut ON u.type_id = ut.type_id
JOIN roles r ON u.role_id = r.role_id;

CREATE VIEW vw_student_enrolments AS
SELECT 
    cts.course_term_id,
    s.student_id,
    u.first_name,
    u.last_name,
    u.email,
    v.course_code,
    v.term_name,
    v.year,
    v.campus_code,
    cts.results
FROM course_term_students cts
JOIN students s ON cts.user_id = s.user_id
JOIN vw_user_directory u ON s.user_id = u.user_id
JOIN vw_course_term_details v ON cts.course_term_id = v.course_term_id;

CREATE VIEW vw_finance_ledger AS
SELECT 
    f.fee_id,
    f.total_amount,
    f.status AS fee_status,
    pp.name AS payment_plan,
    CASE 
        WHEN sf.user_id IS NOT NULL THEN 'B2C Student'
        WHEN bf.business_id IS NOT NULL THEN 'B2B Business'
    END AS payer_type,
    CASE 
        WHEN sf.user_id IS NOT NULL THEN p.first_name || ' ' || p.last_name
        WHEN bf.business_id IS NOT NULL THEN b.company_name
    END AS payer_name
FROM fees f
JOIN payment_plan pp ON f.plan_id = pp.plan_id
LEFT JOIN student_fee sf ON f.fee_id = sf.fee_id
LEFT JOIN profiles p ON sf.user_id = p.user_id
LEFT JOIN business_fee bf ON f.fee_id = bf.fee_id
LEFT JOIN businesses b ON bf.business_id = b.business_id;

CREATE VIEW vw_lecture_timetable AS
SELECT 
    l.lecture_id,
    v.course_code,
    v.term_name,
    v.year,
    l.date,
    l.start_time,
    l.duration_minutes,
    r.room_number,
    b.building_name,
    v.campus_code,
    p.first_name || ' ' || p.last_name AS teacher_name
FROM lectures l
JOIN vw_course_term_details v ON l.course_term_id = v.course_term_id
JOIN rooms r ON l.room_id = r.room_id
JOIN buildings b ON r.building_id = b.building_id
JOIN employees e ON l.user_id = e.user_id
JOIN profiles p ON e.user_id = p.user_id;