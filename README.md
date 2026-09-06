# Oracle 11g RMAN Backup and Disaster Recovery

A practical Oracle Database 11g backup-and-recovery project demonstrating a complete RMAN workflow: ARCHIVELOG configuration, disk backup sets, control-file autobackup, validation, a simulated datafile failure, restore, media recovery, and final data verification.

![RMAN datafile restore and recovery](evidence/02-datafile-restore-and-recovery.png)

## Scenario overview

The lab creates a dedicated `RECOVERY_TS` tablespace and an `RMANLAB.ORDERS` test table. After a full database and archived-redo backup, a fourth row is committed. The tablespace datafile is then moved away from its registered location to simulate a real media failure.

Oracle fails to open with `ORA-01157` and `ORA-01110`. RMAN restores datafile 6 from backup, applies archived redo, opens the database, and recovers all four rows—including the post-backup transaction.

## Technical highlights

- Enabled `ARCHIVELOG` mode and verified the Fast Recovery Area.
- Configured disk `BACKUPSET` output and control-file autobackup.
- Applied a seven-day recovery-window retention policy.
- Executed `BACKUP DATABASE PLUS ARCHIVELOG` and separate SPFILE/control-file backups.
- Validated recoverability with `RESTORE DATABASE VALIDATE`.
- Forced and captured an actual missing-datafile failure.
- Restored and recovered a single datafile using archived redo.
- Verified transactional consistency after media recovery.

## Recovery workflow

1. Inspect the database, DBID, open mode, log mode, and FRA.
2. Enable ARCHIVELOG mode and restart the database.
3. Create isolated test storage and seed data.
4. Configure RMAN and create validated backups.
5. Commit a post-backup transaction and archive the current redo.
6. Move the test datafile to simulate media loss.
7. Restore and recover datafile 6, then open the database.
8. Query the test table and confirm all four rows are present.

## Repository contents

- [`report/Oracle_11g_Backup_Disaster_Recovery_Public.pdf`](report/Oracle_11g_Backup_Disaster_Recovery_Public.pdf) — complete public portfolio report in Arabic and English.
- [`commands/oracle-lab-setup.sql`](commands/oracle-lab-setup.sql) — SQL*Plus setup with an interactive password prompt and explicit `RMANLAB.ORDERS` ownership.
- [`commands/rman-backup-recovery.rman`](commands/rman-backup-recovery.rman) — initial backup and validation phase; does not execute a restore.
- [`commands/rman-archive-redo.rman`](commands/rman-archive-redo.rman) — archives and backs up redo after the post-backup transaction.
- [`commands/rman-restore-recovery.rman`](commands/rman-restore-recovery.rman) — separate recovery phase using the supplied datafile number.
- [`evidence/`](evidence/) — selected screenshots showing backup validation, datafile recovery, and final data verification.

## Evidence

- [Backup validation](evidence/01-backup-validation.png)
- [Datafile restore and media recovery](evidence/02-datafile-restore-and-recovery.png)
- [Recovered data verification](evidence/03-final-data-verification.png)

## Safe usage

Review and run the phases separately:

1. Select the isolated Oracle 11g lab instance and edit `recovery_datafile` in the setup file to a valid path on that database server. Run setup as SYSDBA in a fresh lab; it exits on SQL errors and is not an idempotent migration.
2. Confirm the setup query reports `RMANLAB.ORDERS` in `RECOVERY_TS`. Record the `FILE_ID` and full path returned for that tablespace. The value `6` belongs to the recorded experiment and is not universal.
3. Run the initial backup/validation file using RMAN. Confirm it succeeds before proceeding.
4. In a separate SQL*Plus session as `RMANLAB`, insert and commit one additional test order with an unused ID. Record its values for the final check. Then run `rman-archive-redo.rman`.
5. Follow the report's manual shutdown, test-datafile failure simulation, and `STARTUP MOUNT` sequence, using the verified lab path. No file-moving command is automated by these scripts.
6. Run the restore file with the verified numeric file ID. For example, **only if your lab query returned `6`**:

   ```text
   rman target / cmdfile=commands/rman-restore-recovery.rman using 6
   ```

7. Query `RMANLAB.ORDERS` and confirm the three seed rows and the committed post-backup row are present.

The report and screenshots document the original experiment. The revised scripts have been reviewed statically, but have not been executed against a live Oracle instance during this repository update.

Oracle documents [explicit schema and tablespace selection](https://docs.oracle.com/cd/B28359_01/server.111/b28310/tables003.htm) and [RMAN command files with substitution parameters](https://blogs.oracle.com/connect/scripting-oracle-rman-commands).

Run these commands only in an isolated training database. The workflow changes database operating mode, restarts the instance, creates database objects, and intentionally makes a datafile unavailable.

The student ID, document metadata, and lab password were removed from the public report. The course-assignment brief is intentionally excluded.

