-- Bookings on 2012-09-14 costing more than $30.
-- Guests (memid 0) pay guestcost, members pay membercost; costs are per slot.
-- Output: member name, facility, cost, ordered by cost descending.
select member, facility, cost
from (
    select mb.firstname || ' ' || mb.surname as member,
           fc.name as facility,
           case
               when bk.memid = 0 then fc.guestcost * bk.slots
               else fc.membercost * bk.slots
           end as cost
    from cd.bookings bk
    join cd.facilities fc on fc.facid = bk.facid
    join cd.members mb on mb.memid = bk.memid
    where bk.starttime >= '2012-09-14'
      and bk.starttime < '2012-09-15'
) as bookings_cost
where cost > 30
order by cost desc;
-- Members who have used a tennis court, with the court name.
-- No duplicates; ordered by member, then facility.
select distinct mb.firstname || ' ' || mb.surname as member,
       fc.name as facility
from cd.bookings bk
join cd.facilities fc on fc.facid = bk.facid
join cd.members mb on mb.memid = bk.memid
where fc.name like 'Tennis Court%'
order by member, facility;

-- All members with the member who recommended them, without using a join.
-- The subquery runs once per row and looks up that member's recommender.
select distinct mb.firstname || ' ' || mb.surname as member,
       (select rec.firstname || ' ' || rec.surname
        from cd.members rec
        where rec.memid = mb.recommendedby) as recommender
from cd.members mb
order by member;