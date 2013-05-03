CREATE VIEW reg_with_notes as
select r.*, n.note_text from registrations r, registration_notes rn, notes n where r.reg_id = rn.reg_id and rn.note_id = n.note_id;

