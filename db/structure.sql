--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activities (
    id integer NOT NULL,
    user_id integer,
    contact_id integer,
    note text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted integer DEFAULT 0
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: agents_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE agents_contacts (
    id integer NOT NULL,
    agent_id integer,
    contact_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: agents_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agents_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agents_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agents_contacts_id_seq OWNED BY agents_contacts.id;


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assignments (
    id integer NOT NULL,
    user_id integer,
    role_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assignments_id_seq OWNED BY assignments.id;


--
-- Name: autotask_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE autotask_details (
    id integer NOT NULL,
    autotask_id integer,
    item_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: autotask_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE autotask_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autotask_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE autotask_details_id_seq OWNED BY autotask_details.id;


--
-- Name: autotasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE autotasks (
    id integer NOT NULL,
    name character varying,
    time_interval integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: autotasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE autotasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autotasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE autotasks_id_seq OWNED BY autotasks.id;


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bank_accounts (
    id integer NOT NULL,
    name character varying,
    bank_name text,
    account_name text,
    account_number character varying,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status text,
    parent_id integer,
    annoucing_user_ids text
);


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bank_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bank_accounts_id_seq OWNED BY bank_accounts.id;


--
-- Name: book_prices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE book_prices (
    id integer NOT NULL,
    book_id integer,
    prices text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: book_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE book_prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: book_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE book_prices_id_seq OWNED BY book_prices.id;


--
-- Name: books; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE books (
    id integer NOT NULL,
    name character varying,
    description text,
    user_id integer,
    image character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    publisher character varying,
    price numeric,
    parent_id integer,
    course_type_ids text,
    subject_ids text,
    annoucing_user_ids text,
    status text,
    course_type_id integer,
    subject_id integer,
    stock_type_id integer
);


--
-- Name: books_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE books_contacts (
    id integer NOT NULL,
    course_register_id integer,
    book_id integer,
    contact_id integer,
    price numeric,
    discount_program_id integer,
    discount numeric,
    volumn_ids text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    quantity integer,
    cache_delivery_status text,
    upfront boolean DEFAULT false
);


--
-- Name: books_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE books_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE books_contacts_id_seq OWNED BY books_contacts.id;


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE books_id_seq OWNED BY books.id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cities (
    id integer NOT NULL,
    name character varying,
    state_id integer,
    city_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cities_id_seq OWNED BY cities.id;


--
-- Name: city_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE city_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: city_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE city_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: city_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE city_types_id_seq OWNED BY city_types.id;


--
-- Name: contact_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_tags (
    id integer NOT NULL,
    name character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    annoucing_user_ids text,
    parent_id integer,
    status text,
    user_id integer
);


--
-- Name: contact_tags_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_tags_contacts (
    id integer NOT NULL,
    contact_id integer,
    contact_tag_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contact_tags_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_tags_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_tags_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_tags_contacts_id_seq OWNED BY contact_tags_contacts.id;


--
-- Name: contact_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_tags_id_seq OWNED BY contact_tags.id;


--
-- Name: contact_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    display_order integer
);


--
-- Name: contact_types_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_types_contacts (
    id integer NOT NULL,
    contact_id integer,
    contact_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contact_types_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_types_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_types_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_types_contacts_id_seq OWNED BY contact_types_contacts.id;


--
-- Name: contact_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_types_id_seq OWNED BY contact_types.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts (
    id integer NOT NULL,
    name character varying,
    phone character varying,
    mobile character varying,
    fax character varying,
    email character varying,
    address character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tax_code character varying,
    note text,
    contact_type_id integer,
    website character varying,
    account_number character varying,
    bank character varying,
    representative character varying,
    representative_role character varying,
    representative_phone character varying,
    is_mine boolean DEFAULT false,
    hotline character varying,
    city_id integer,
    contact_types_cache character varying,
    image character varying,
    user_id integer,
    first_name character varying,
    last_name character varying,
    mobile_2 character varying,
    email_2 character varying,
    is_individual boolean DEFAULT true,
    sex character varying,
    referrer_id integer,
    birthday date,
    tag_id integer,
    mailing_address character varying,
    payment_type character varying,
    invoice_info_id integer,
    invoice_required boolean DEFAULT false,
    cache_course_type_ids text,
    cache_intakes text,
    cache_subjects text,
    base_id character varying,
    base_password character varying,
    account_manager_id integer,
    preferred_mailing character varying,
    bases text,
    status text,
    draft_for integer,
    "tmp_StudentID" text,
    annoucing_user_ids text,
    creator_id integer,
    cache_search text
);


--
-- Name: contacts_course_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts_course_types (
    id integer NOT NULL,
    contact_id integer,
    course_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contacts_course_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_course_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_course_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_course_types_id_seq OWNED BY contacts_course_types.id;


--
-- Name: contacts_courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts_courses (
    id integer NOT NULL,
    contact_id integer,
    course_id integer,
    course_register_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    courses_phrase_ids character varying,
    upfront boolean,
    price numeric,
    discount_program_id integer,
    discount numeric,
    report boolean DEFAULT true,
    discount_programs text,
    other_discounts text,
    cache_payment_status text,
    hour numeric,
    money numeric,
    additional_money numeric
);


--
-- Name: contacts_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_courses_id_seq OWNED BY contacts_courses.id;


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: contacts_lecturer_course_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts_lecturer_course_types (
    id integer NOT NULL,
    contact_id integer,
    course_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contacts_lecturer_course_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_lecturer_course_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_lecturer_course_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_lecturer_course_types_id_seq OWNED BY contacts_lecturer_course_types.id;


--
-- Name: contacts_seminars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts_seminars (
    id integer NOT NULL,
    contact_id integer,
    seminar_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    present boolean DEFAULT false
);


--
-- Name: contacts_seminars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_seminars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_seminars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_seminars_id_seq OWNED BY contacts_seminars.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: course_prices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_prices (
    id integer NOT NULL,
    course_id integer,
    prices text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    amount numeric,
    deadline timestamp without time zone
);


--
-- Name: course_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_prices_id_seq OWNED BY course_prices.id;


--
-- Name: course_registers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_registers (
    id integer NOT NULL,
    created_date timestamp without time zone,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mailing_address character varying,
    payment_type character varying,
    bank_account_id integer,
    discount_program_id integer,
    contact_id integer,
    vat_name character varying,
    vat_code character varying,
    vat_address character varying,
    invoice_required boolean,
    debt_date timestamp without time zone,
    cache_delivery_status character varying,
    cache_payment_status character varying,
    transfer numeric,
    discount numeric,
    transfer_hour numeric,
    annoucing_user_ids text,
    parent_id integer,
    status text,
    sponsored_company_id integer,
    preferred_mailing character varying,
    account_manager_id integer,
    cache_search text
);


--
-- Name: course_registers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_registers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_registers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_registers_id_seq OWNED BY course_registers.id;


--
-- Name: course_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_types (
    id integer NOT NULL,
    name character varying,
    short_name character varying,
    description text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "tmp_CourseTypeID" text,
    status text,
    annoucing_user_ids text,
    parent_id integer
);


--
-- Name: course_types_discount_programs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_types_discount_programs (
    id integer NOT NULL,
    course_type_id integer,
    discount_program_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: course_types_discount_programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_types_discount_programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_types_discount_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_types_discount_programs_id_seq OWNED BY course_types_discount_programs.id;


--
-- Name: course_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_types_id_seq OWNED BY course_types.id;


--
-- Name: course_types_subjects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_types_subjects (
    id integer NOT NULL,
    course_type_id integer,
    subject_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: course_types_subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_types_subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_types_subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_types_subjects_id_seq OWNED BY course_types_subjects.id;


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE courses (
    id integer NOT NULL,
    description text,
    user_id integer,
    course_type_id integer,
    intake date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    subject_id integer,
    lecturer_id integer,
    status text,
    parent_id integer,
    for_exam_year integer,
    for_exam_month character varying,
    annoucing_user_ids text,
    upfront boolean
);


--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE courses_id_seq OWNED BY courses.id;


--
-- Name: courses_phrases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE courses_phrases (
    id integer NOT NULL,
    course_id integer,
    phrase_id integer,
    start_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hour integer
);


--
-- Name: courses_phrases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE courses_phrases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_phrases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE courses_phrases_id_seq OWNED BY courses_phrases.id;


--
-- Name: deliveries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE deliveries (
    id integer NOT NULL,
    course_register_id integer,
    contact_id integer,
    delivery_date timestamp without time zone,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer
);


--
-- Name: deliveries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE deliveries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deliveries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE deliveries_id_seq OWNED BY deliveries.id;


--
-- Name: delivery_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delivery_details (
    id integer NOT NULL,
    delivery_id integer,
    book_id integer,
    quantity integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delivery_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delivery_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delivery_details_id_seq OWNED BY delivery_details.id;


--
-- Name: discount_programs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE discount_programs (
    id integer NOT NULL,
    name character varying,
    description text,
    user_id integer,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    rate numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type_name character varying,
    status text,
    annoucing_user_ids text,
    parent_id integer
);


--
-- Name: discount_programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE discount_programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discount_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE discount_programs_id_seq OWNED BY discount_programs.id;


--
-- Name: headshot_photos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE headshot_photos (
    id integer NOT NULL,
    description character varying,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    capturable_id integer,
    capturable_type character varying,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: headshot_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE headshot_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: headshot_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE headshot_photos_id_seq OWNED BY headshot_photos.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer,
    sender_id integer,
    title text,
    description text,
    viewed integer DEFAULT 0,
    url text,
    icon text,
    type_name text,
    item_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: parent_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE parent_contacts (
    id integer NOT NULL,
    contact_id integer,
    parent_id integer
);


--
-- Name: parent_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parent_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parent_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parent_contacts_id_seq OWNED BY parent_contacts.id;


--
-- Name: payment_record_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_record_details (
    id integer NOT NULL,
    contacts_course_id integer,
    books_contact_id numeric,
    amount numeric,
    payment_record_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    total numeric,
    course_type_id integer
);


--
-- Name: payment_record_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_record_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_record_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_record_details_id_seq OWNED BY payment_record_details.id;


--
-- Name: payment_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_records (
    id integer NOT NULL,
    course_register_id integer,
    debt_date timestamp without time zone,
    bank_account_id integer,
    user_id integer,
    note text,
    payment_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer,
    bank_ref character varying,
    course_register_ids text,
    company_id integer,
    amount numeric,
    parent_id integer,
    cache_payment_status character varying,
    transfer_id integer,
    cache_search text
);


--
-- Name: payment_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_records_id_seq OWNED BY payment_records.id;


--
-- Name: phrases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE phrases (
    id integer NOT NULL,
    name character varying,
    description text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status text,
    parent_id integer,
    annoucing_user_ids text
);


--
-- Name: phrases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE phrases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phrases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phrases_id_seq OWNED BY phrases.id;


--
-- Name: phrases_subjects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE phrases_subjects (
    id integer NOT NULL,
    phrase_id integer,
    subject_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: phrases_subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE phrases_subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phrases_subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phrases_subjects_id_seq OWNED BY phrases_subjects.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: seminars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE seminars (
    id integer NOT NULL,
    name character varying,
    description text,
    start_at timestamp without time zone,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    course_type_id integer,
    status text,
    parent_id integer,
    annoucing_user_ids text
);


--
-- Name: seminars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE seminars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seminars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE seminars_id_seq OWNED BY seminars.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    name character varying,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: stock_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stock_types (
    id integer NOT NULL,
    name character varying,
    description text,
    user_id integer,
    annoucing_user_ids text,
    parent_id integer,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stock_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stock_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stock_types_id_seq OWNED BY stock_types.id;


--
-- Name: stock_updates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stock_updates (
    id integer NOT NULL,
    type_name character varying,
    book_id integer,
    quantity integer,
    created_date timestamp without time zone,
    user_id integer,
    note text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    destination text
);


--
-- Name: stock_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stock_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stock_updates_id_seq OWNED BY stock_updates.id;


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subjects (
    id integer NOT NULL,
    name character varying,
    description text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "tmp_SubjectID" text,
    annoucing_user_ids text,
    parent_id integer,
    status text
);


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subjects_id_seq OWNED BY subjects.id;


--
-- Name: transfer_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transfer_details (
    id integer NOT NULL,
    transfer_id integer,
    contacts_course_id integer,
    courses_phrase_ids text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: transfer_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transfer_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transfer_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transfer_details_id_seq OWNED BY transfer_details.id;


--
-- Name: transfers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transfers (
    id integer NOT NULL,
    contact_id integer,
    user_id integer,
    transfer_date timestamp without time zone,
    hour numeric,
    money numeric,
    admin_fee numeric,
    transfer_for integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status text,
    parent_id integer,
    annoucing_user_ids text,
    course_id integer,
    to_contact_id integer,
    to_course_id integer,
    to_courses_phrase_ids text,
    courses_phrase_ids text,
    to_type character varying,
    to_course_hour numeric,
    to_course_money numeric,
    cache_payment_status text,
    from_hour text
);


--
-- Name: transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transfers_id_seq OWNED BY transfers.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    first_name character varying,
    last_name character varying,
    phone_ext character varying,
    mobile character varying,
    image character varying,
    "tmp_ConsultantID" text,
    name text
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agents_contacts ALTER COLUMN id SET DEFAULT nextval('agents_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments ALTER COLUMN id SET DEFAULT nextval('assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY autotask_details ALTER COLUMN id SET DEFAULT nextval('autotask_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY autotasks ALTER COLUMN id SET DEFAULT nextval('autotasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_accounts ALTER COLUMN id SET DEFAULT nextval('bank_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_prices ALTER COLUMN id SET DEFAULT nextval('book_prices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY books ALTER COLUMN id SET DEFAULT nextval('books_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY books_contacts ALTER COLUMN id SET DEFAULT nextval('books_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cities ALTER COLUMN id SET DEFAULT nextval('cities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY city_types ALTER COLUMN id SET DEFAULT nextval('city_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_tags ALTER COLUMN id SET DEFAULT nextval('contact_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_tags_contacts ALTER COLUMN id SET DEFAULT nextval('contact_tags_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_types ALTER COLUMN id SET DEFAULT nextval('contact_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_types_contacts ALTER COLUMN id SET DEFAULT nextval('contact_types_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts_course_types ALTER COLUMN id SET DEFAULT nextval('contacts_course_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts_courses ALTER COLUMN id SET DEFAULT nextval('contacts_courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts_lecturer_course_types ALTER COLUMN id SET DEFAULT nextval('contacts_lecturer_course_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts_seminars ALTER COLUMN id SET DEFAULT nextval('contacts_seminars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_prices ALTER COLUMN id SET DEFAULT nextval('course_prices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_registers ALTER COLUMN id SET DEFAULT nextval('course_registers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_types ALTER COLUMN id SET DEFAULT nextval('course_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_types_discount_programs ALTER COLUMN id SET DEFAULT nextval('course_types_discount_programs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_types_subjects ALTER COLUMN id SET DEFAULT nextval('course_types_subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses ALTER COLUMN id SET DEFAULT nextval('courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses_phrases ALTER COLUMN id SET DEFAULT nextval('courses_phrases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY deliveries ALTER COLUMN id SET DEFAULT nextval('deliveries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delivery_details ALTER COLUMN id SET DEFAULT nextval('delivery_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY discount_programs ALTER COLUMN id SET DEFAULT nextval('discount_programs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY headshot_photos ALTER COLUMN id SET DEFAULT nextval('headshot_photos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parent_contacts ALTER COLUMN id SET DEFAULT nextval('parent_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_record_details ALTER COLUMN id SET DEFAULT nextval('payment_record_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_records ALTER COLUMN id SET DEFAULT nextval('payment_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY phrases ALTER COLUMN id SET DEFAULT nextval('phrases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY phrases_subjects ALTER COLUMN id SET DEFAULT nextval('phrases_subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY seminars ALTER COLUMN id SET DEFAULT nextval('seminars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stock_types ALTER COLUMN id SET DEFAULT nextval('stock_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stock_updates ALTER COLUMN id SET DEFAULT nextval('stock_updates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subjects ALTER COLUMN id SET DEFAULT nextval('subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transfer_details ALTER COLUMN id SET DEFAULT nextval('transfer_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transfers ALTER COLUMN id SET DEFAULT nextval('transfers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: agents_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agents_contacts
    ADD CONSTRAINT agents_contacts_pkey PRIMARY KEY (id);


--
-- Name: assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: autotask_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autotask_details
    ADD CONSTRAINT autotask_details_pkey PRIMARY KEY (id);


--
-- Name: autotasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autotasks
    ADD CONSTRAINT autotasks_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: book_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY book_prices
    ADD CONSTRAINT book_prices_pkey PRIMARY KEY (id);


--
-- Name: books_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY books_contacts
    ADD CONSTRAINT books_contacts_pkey PRIMARY KEY (id);


--
-- Name: books_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: city_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY city_types
    ADD CONSTRAINT city_types_pkey PRIMARY KEY (id);


--
-- Name: contact_tags_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_tags_contacts
    ADD CONSTRAINT contact_tags_contacts_pkey PRIMARY KEY (id);


--
-- Name: contact_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_tags
    ADD CONSTRAINT contact_tags_pkey PRIMARY KEY (id);


--
-- Name: contact_types_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_types_contacts
    ADD CONSTRAINT contact_types_contacts_pkey PRIMARY KEY (id);


--
-- Name: contact_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_types
    ADD CONSTRAINT contact_types_pkey PRIMARY KEY (id);


--
-- Name: contacts_course_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts_course_types
    ADD CONSTRAINT contacts_course_types_pkey PRIMARY KEY (id);


--
-- Name: contacts_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts_courses
    ADD CONSTRAINT contacts_courses_pkey PRIMARY KEY (id);


--
-- Name: contacts_lecturer_course_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts_lecturer_course_types
    ADD CONSTRAINT contacts_lecturer_course_types_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: contacts_seminars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts_seminars
    ADD CONSTRAINT contacts_seminars_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: course_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_prices
    ADD CONSTRAINT course_prices_pkey PRIMARY KEY (id);


--
-- Name: course_registers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_registers
    ADD CONSTRAINT course_registers_pkey PRIMARY KEY (id);


--
-- Name: course_types_discount_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_types_discount_programs
    ADD CONSTRAINT course_types_discount_programs_pkey PRIMARY KEY (id);


--
-- Name: course_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_types
    ADD CONSTRAINT course_types_pkey PRIMARY KEY (id);


--
-- Name: course_types_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_types_subjects
    ADD CONSTRAINT course_types_subjects_pkey PRIMARY KEY (id);


--
-- Name: courses_phrases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY courses_phrases
    ADD CONSTRAINT courses_phrases_pkey PRIMARY KEY (id);


--
-- Name: courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- Name: delivery_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delivery_details
    ADD CONSTRAINT delivery_details_pkey PRIMARY KEY (id);


--
-- Name: discount_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY discount_programs
    ADD CONSTRAINT discount_programs_pkey PRIMARY KEY (id);


--
-- Name: headshot_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY headshot_photos
    ADD CONSTRAINT headshot_photos_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: parent_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY parent_contacts
    ADD CONSTRAINT parent_contacts_pkey PRIMARY KEY (id);


--
-- Name: payment_record_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_record_details
    ADD CONSTRAINT payment_record_details_pkey PRIMARY KEY (id);


--
-- Name: payment_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_records
    ADD CONSTRAINT payment_records_pkey PRIMARY KEY (id);


--
-- Name: phrases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY phrases
    ADD CONSTRAINT phrases_pkey PRIMARY KEY (id);


--
-- Name: phrases_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY phrases_subjects
    ADD CONSTRAINT phrases_subjects_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: seminars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY seminars
    ADD CONSTRAINT seminars_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: stock_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stock_types
    ADD CONSTRAINT stock_types_pkey PRIMARY KEY (id);


--
-- Name: stock_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stock_updates
    ADD CONSTRAINT stock_updates_pkey PRIMARY KEY (id);


--
-- Name: subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: transfer_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transfer_details
    ADD CONSTRAINT transfer_details_pkey PRIMARY KEY (id);


--
-- Name: transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transfers
    ADD CONSTRAINT transfers_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140213022040');

INSERT INTO schema_migrations (version) VALUES ('20140213061224');

INSERT INTO schema_migrations (version) VALUES ('20140213063536');

INSERT INTO schema_migrations (version) VALUES ('20140214075905');

INSERT INTO schema_migrations (version) VALUES ('20140215020028');

INSERT INTO schema_migrations (version) VALUES ('20140215020559');

INSERT INTO schema_migrations (version) VALUES ('20140221041317');

INSERT INTO schema_migrations (version) VALUES ('20140221070917');

INSERT INTO schema_migrations (version) VALUES ('20140222045115');

INSERT INTO schema_migrations (version) VALUES ('20140222045217');

INSERT INTO schema_migrations (version) VALUES ('20140222045430');

INSERT INTO schema_migrations (version) VALUES ('20140222045454');

INSERT INTO schema_migrations (version) VALUES ('20140222045516');

INSERT INTO schema_migrations (version) VALUES ('20140222052130');

INSERT INTO schema_migrations (version) VALUES ('20140307061621');

INSERT INTO schema_migrations (version) VALUES ('20140307063529');

INSERT INTO schema_migrations (version) VALUES ('20140313080139');

INSERT INTO schema_migrations (version) VALUES ('20140313080223');

INSERT INTO schema_migrations (version) VALUES ('20140314070155');

INSERT INTO schema_migrations (version) VALUES ('20140320014111');

INSERT INTO schema_migrations (version) VALUES ('20140320014913');

INSERT INTO schema_migrations (version) VALUES ('20140815013938');

INSERT INTO schema_migrations (version) VALUES ('20150327035733');

INSERT INTO schema_migrations (version) VALUES ('20150423011049');

INSERT INTO schema_migrations (version) VALUES ('20150423012413');

INSERT INTO schema_migrations (version) VALUES ('20150505075859');

INSERT INTO schema_migrations (version) VALUES ('20150512015924');

INSERT INTO schema_migrations (version) VALUES ('20150512015947');

INSERT INTO schema_migrations (version) VALUES ('20150512020020');

INSERT INTO schema_migrations (version) VALUES ('20150512020037');

INSERT INTO schema_migrations (version) VALUES ('20150512025921');

INSERT INTO schema_migrations (version) VALUES ('20150521030440');

INSERT INTO schema_migrations (version) VALUES ('20150604092249');

INSERT INTO schema_migrations (version) VALUES ('20150625041353');

INSERT INTO schema_migrations (version) VALUES ('20150629031144');

INSERT INTO schema_migrations (version) VALUES ('20150629074251');

INSERT INTO schema_migrations (version) VALUES ('20150629081809');

INSERT INTO schema_migrations (version) VALUES ('20150630052736');

INSERT INTO schema_migrations (version) VALUES ('20150630052750');

INSERT INTO schema_migrations (version) VALUES ('20150630054342');

INSERT INTO schema_migrations (version) VALUES ('20150630054356');

INSERT INTO schema_migrations (version) VALUES ('20150630061658');

INSERT INTO schema_migrations (version) VALUES ('20150630071514');

INSERT INTO schema_migrations (version) VALUES ('20150630092753');

INSERT INTO schema_migrations (version) VALUES ('20150701020801');

INSERT INTO schema_migrations (version) VALUES ('20150701034859');

INSERT INTO schema_migrations (version) VALUES ('20150701074441');

INSERT INTO schema_migrations (version) VALUES ('20150701075243');

INSERT INTO schema_migrations (version) VALUES ('20150702041941');

INSERT INTO schema_migrations (version) VALUES ('20150704014135');

INSERT INTO schema_migrations (version) VALUES ('20150704015540');

INSERT INTO schema_migrations (version) VALUES ('20150704020556');

INSERT INTO schema_migrations (version) VALUES ('20150704021106');

INSERT INTO schema_migrations (version) VALUES ('20150706011841');

INSERT INTO schema_migrations (version) VALUES ('20150706014628');

INSERT INTO schema_migrations (version) VALUES ('20150706041513');

INSERT INTO schema_migrations (version) VALUES ('20150706065701');

INSERT INTO schema_migrations (version) VALUES ('20150706065821');

INSERT INTO schema_migrations (version) VALUES ('20150706080457');

INSERT INTO schema_migrations (version) VALUES ('20150706082550');

INSERT INTO schema_migrations (version) VALUES ('20150706085609');

INSERT INTO schema_migrations (version) VALUES ('20150708012614');

INSERT INTO schema_migrations (version) VALUES ('20150708012710');

INSERT INTO schema_migrations (version) VALUES ('20150708014434');

INSERT INTO schema_migrations (version) VALUES ('20150708023427');

INSERT INTO schema_migrations (version) VALUES ('20150708053215');

INSERT INTO schema_migrations (version) VALUES ('20150709015943');

INSERT INTO schema_migrations (version) VALUES ('20150710072419');

INSERT INTO schema_migrations (version) VALUES ('20150710072433');

INSERT INTO schema_migrations (version) VALUES ('20150710073708');

INSERT INTO schema_migrations (version) VALUES ('20150713012339');

INSERT INTO schema_migrations (version) VALUES ('20150713012541');

INSERT INTO schema_migrations (version) VALUES ('20150713015522');

INSERT INTO schema_migrations (version) VALUES ('20150713021606');

INSERT INTO schema_migrations (version) VALUES ('20150713024929');

INSERT INTO schema_migrations (version) VALUES ('20150713030131');

INSERT INTO schema_migrations (version) VALUES ('20150713085842');

INSERT INTO schema_migrations (version) VALUES ('20150713100153');

INSERT INTO schema_migrations (version) VALUES ('20150714062706');

INSERT INTO schema_migrations (version) VALUES ('20150715082317');

INSERT INTO schema_migrations (version) VALUES ('20150718020013');

INSERT INTO schema_migrations (version) VALUES ('20150718020635');

INSERT INTO schema_migrations (version) VALUES ('20150718022427');

INSERT INTO schema_migrations (version) VALUES ('20150718031753');

INSERT INTO schema_migrations (version) VALUES ('20150721010201');

INSERT INTO schema_migrations (version) VALUES ('20150721093740');

INSERT INTO schema_migrations (version) VALUES ('20150722012329');

INSERT INTO schema_migrations (version) VALUES ('20150722023212');

INSERT INTO schema_migrations (version) VALUES ('20150722025229');

INSERT INTO schema_migrations (version) VALUES ('20150722072736');

INSERT INTO schema_migrations (version) VALUES ('20150722072818');

INSERT INTO schema_migrations (version) VALUES ('20150722072844');

INSERT INTO schema_migrations (version) VALUES ('20150722072925');

INSERT INTO schema_migrations (version) VALUES ('20150722080904');

INSERT INTO schema_migrations (version) VALUES ('20150722085855');

INSERT INTO schema_migrations (version) VALUES ('20150722085921');

INSERT INTO schema_migrations (version) VALUES ('20150722085952');

INSERT INTO schema_migrations (version) VALUES ('20150722090024');

INSERT INTO schema_migrations (version) VALUES ('20150723013855');

INSERT INTO schema_migrations (version) VALUES ('20150727025749');

INSERT INTO schema_migrations (version) VALUES ('20150727025802');

INSERT INTO schema_migrations (version) VALUES ('20150727025816');

INSERT INTO schema_migrations (version) VALUES ('20150727033034');

INSERT INTO schema_migrations (version) VALUES ('20150727063109');

INSERT INTO schema_migrations (version) VALUES ('20150727065758');

INSERT INTO schema_migrations (version) VALUES ('20150727070153');

INSERT INTO schema_migrations (version) VALUES ('20150728090215');

INSERT INTO schema_migrations (version) VALUES ('20150729010405');

INSERT INTO schema_migrations (version) VALUES ('20150729020843');

INSERT INTO schema_migrations (version) VALUES ('20150729034433');

INSERT INTO schema_migrations (version) VALUES ('20150729034451');

INSERT INTO schema_migrations (version) VALUES ('20150729042837');

INSERT INTO schema_migrations (version) VALUES ('20150729042854');

INSERT INTO schema_migrations (version) VALUES ('20150730013825');

INSERT INTO schema_migrations (version) VALUES ('20150803043519');

INSERT INTO schema_migrations (version) VALUES ('20150805015401');

INSERT INTO schema_migrations (version) VALUES ('20150805072337');

INSERT INTO schema_migrations (version) VALUES ('20150811004205');

INSERT INTO schema_migrations (version) VALUES ('20150811022717');

INSERT INTO schema_migrations (version) VALUES ('20150818012431');

INSERT INTO schema_migrations (version) VALUES ('20150818012500');

INSERT INTO schema_migrations (version) VALUES ('20150821033006');

INSERT INTO schema_migrations (version) VALUES ('20150825073356');

INSERT INTO schema_migrations (version) VALUES ('20150825074720');

INSERT INTO schema_migrations (version) VALUES ('20150825075717');

INSERT INTO schema_migrations (version) VALUES ('20150825080624');

INSERT INTO schema_migrations (version) VALUES ('20150825091546');

INSERT INTO schema_migrations (version) VALUES ('20150826024703');

INSERT INTO schema_migrations (version) VALUES ('20150826040511');

INSERT INTO schema_migrations (version) VALUES ('20150826040701');

INSERT INTO schema_migrations (version) VALUES ('20150828084243');

INSERT INTO schema_migrations (version) VALUES ('20150828084433');

INSERT INTO schema_migrations (version) VALUES ('20150828091606');

INSERT INTO schema_migrations (version) VALUES ('20150831092449');

INSERT INTO schema_migrations (version) VALUES ('20150831093658');

INSERT INTO schema_migrations (version) VALUES ('20150901010656');

INSERT INTO schema_migrations (version) VALUES ('20150903014954');

INSERT INTO schema_migrations (version) VALUES ('20150904014852');

INSERT INTO schema_migrations (version) VALUES ('20150904022843');

INSERT INTO schema_migrations (version) VALUES ('20150904065003');

INSERT INTO schema_migrations (version) VALUES ('20150904065145');

INSERT INTO schema_migrations (version) VALUES ('20150904065449');

INSERT INTO schema_migrations (version) VALUES ('20150905003459');

INSERT INTO schema_migrations (version) VALUES ('20150905003514');

INSERT INTO schema_migrations (version) VALUES ('20150905013913');

INSERT INTO schema_migrations (version) VALUES ('20150905013949');

INSERT INTO schema_migrations (version) VALUES ('20150905014010');

INSERT INTO schema_migrations (version) VALUES ('20150905022506');

INSERT INTO schema_migrations (version) VALUES ('20150905022524');

INSERT INTO schema_migrations (version) VALUES ('20150905022541');

INSERT INTO schema_migrations (version) VALUES ('20150905030020');

INSERT INTO schema_migrations (version) VALUES ('20150905030034');

INSERT INTO schema_migrations (version) VALUES ('20150905030048');

INSERT INTO schema_migrations (version) VALUES ('20150905031617');

INSERT INTO schema_migrations (version) VALUES ('20150905033130');

INSERT INTO schema_migrations (version) VALUES ('20150905033259');

INSERT INTO schema_migrations (version) VALUES ('20150905033312');

INSERT INTO schema_migrations (version) VALUES ('20150906012325');

INSERT INTO schema_migrations (version) VALUES ('20150906012339');

INSERT INTO schema_migrations (version) VALUES ('20150906012354');

INSERT INTO schema_migrations (version) VALUES ('20150906021405');

INSERT INTO schema_migrations (version) VALUES ('20150906021424');

INSERT INTO schema_migrations (version) VALUES ('20150906021438');

INSERT INTO schema_migrations (version) VALUES ('20150906023914');

INSERT INTO schema_migrations (version) VALUES ('20150906023947');

INSERT INTO schema_migrations (version) VALUES ('20150906024011');

INSERT INTO schema_migrations (version) VALUES ('20150906042736');

INSERT INTO schema_migrations (version) VALUES ('20150906042756');

INSERT INTO schema_migrations (version) VALUES ('20150906042814');

INSERT INTO schema_migrations (version) VALUES ('20150914020213');

INSERT INTO schema_migrations (version) VALUES ('20150914061927');

INSERT INTO schema_migrations (version) VALUES ('20150914062159');

INSERT INTO schema_migrations (version) VALUES ('20150914082405');

INSERT INTO schema_migrations (version) VALUES ('20150915002736');

INSERT INTO schema_migrations (version) VALUES ('20150915022953');

INSERT INTO schema_migrations (version) VALUES ('20150915063100');

INSERT INTO schema_migrations (version) VALUES ('20150916063216');

INSERT INTO schema_migrations (version) VALUES ('20150916080604');

INSERT INTO schema_migrations (version) VALUES ('20150917032403');

INSERT INTO schema_migrations (version) VALUES ('20150917032423');

INSERT INTO schema_migrations (version) VALUES ('20150917034058');

INSERT INTO schema_migrations (version) VALUES ('20150917065826');

INSERT INTO schema_migrations (version) VALUES ('20150917084811');

INSERT INTO schema_migrations (version) VALUES ('20150919012300');

INSERT INTO schema_migrations (version) VALUES ('20150919020639');

INSERT INTO schema_migrations (version) VALUES ('20150921022253');

INSERT INTO schema_migrations (version) VALUES ('20150922022436');

INSERT INTO schema_migrations (version) VALUES ('20150922061328');

INSERT INTO schema_migrations (version) VALUES ('20150922083840');

INSERT INTO schema_migrations (version) VALUES ('20150922085050');

INSERT INTO schema_migrations (version) VALUES ('20150922090434');

INSERT INTO schema_migrations (version) VALUES ('20150923012830');

INSERT INTO schema_migrations (version) VALUES ('20150923023541');

INSERT INTO schema_migrations (version) VALUES ('20150924005949');

INSERT INTO schema_migrations (version) VALUES ('20150924011036');

INSERT INTO schema_migrations (version) VALUES ('20150924011052');

INSERT INTO schema_migrations (version) VALUES ('20150924032918');

INSERT INTO schema_migrations (version) VALUES ('20150924034522');

INSERT INTO schema_migrations (version) VALUES ('20150925011740');

INSERT INTO schema_migrations (version) VALUES ('20150925011752');

INSERT INTO schema_migrations (version) VALUES ('20150928015218');

INSERT INTO schema_migrations (version) VALUES ('20150928040432');

INSERT INTO schema_migrations (version) VALUES ('20150928065302');

INSERT INTO schema_migrations (version) VALUES ('20150928065317');

INSERT INTO schema_migrations (version) VALUES ('20150928111009');

INSERT INTO schema_migrations (version) VALUES ('20150928111201');

INSERT INTO schema_migrations (version) VALUES ('20150929010152');

INSERT INTO schema_migrations (version) VALUES ('20150929025355');

INSERT INTO schema_migrations (version) VALUES ('20150929030738');

INSERT INTO schema_migrations (version) VALUES ('20150929035828');

INSERT INTO schema_migrations (version) VALUES ('20150930022051');

INSERT INTO schema_migrations (version) VALUES ('20150930040411');

INSERT INTO schema_migrations (version) VALUES ('20150930061037');

