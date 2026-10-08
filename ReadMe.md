# Learning Management System (LMS) Database Architecture

*Note: This repository showcases my university database architecture project. It showcases the final schema design, business logic implementation, and SQL scripts.*

## The Objective
Build a scalable relational database schema for an international training provider which operates on both B2B and B2C business models. The design efficiently manages complex teacher, student, and course data while enforcing strict data integrity for precise financial auditing.


## Tech Stack & Notations
*   **Database Engine:** SQLite used for a quick demonstration of this prototype.
*   **Development:** SQLiteStudio
*   **Design Notations:** Chen-like and Crow's foot Entity-Relationship Diagrams (ERD)

## Repository Structure
*   `schema_creation.sql` - The foundational DDL script defining all tables, primary/foreign keys, and data types.
*   `docs` - Contains the original ERD files. (Needs drawio to be accessed)
*   `assets` - Contains images of the major sections of the ERD's for demonstration.

## Chen-Like ERD

See more detailed images in the assests section
![Chen-Like ERD](./assets/Chen-Like%20ERD.png)

## Technical Highlights

### 1. Role-Based Access Control (RBAC)
* A centralised `users` table was used in order to separate authentication, personal profiles, and operational roles.
* A dynamic permissions model allowing staff to transition between teaching, support, and management functions without duplicating data.
* Implemented a hierarchical tracking for B2B corporate clients and their associated student cohorts.

### 2. Financial Ledger
* Designed a robust fee and installment architecture capable of handling fluctuating annual pricing structures. 
* Implemented `ON DELETE RESTRICT` on all financial foreign keys to guarantee that deleting a user or deprecating a course never orphans payment records or corrupts historical B2C/B2B revenue reporting.
* Created an abstracted `vw_finance_ledger` view to seamlessly aggregate complex payment plans into unified financial statements.

### 3. Academic Pipeline & Delivery
* Desinged strict cardinality rules for the academic lifecycle (Prerequisites → Terms → Courses → Lectures → Certificates).

