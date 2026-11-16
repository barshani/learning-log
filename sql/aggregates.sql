-- Facility with the highest number of slots booked.
with facility_slots as (
    select facid, sum(slots) as totalslots
    from cd.bookings
    group by facid
)
select facid, totalslots
from facility_slots
where totalslots = (select max(totalslots) from facility_slots);

-- Facilities with total revenue under 1000, lowest first.
-- Revenue = slots booked x price per slot.
-- Guests (memid 0) pay guestcost, members pay membercost.
-- Written with a CTE: first compute revenue per facility, then filter.
with facility_revenue as (
    select fc.name,
           sum(bk.slots *
               case
                   when bk.memid = 0 then fc.guestcost
                   else fc.membercost
               end) as revenue
    from cd.bookings bk
    join cd.facilities fc on bk.facid = fc.facid
    group by fc.facid, fc.name
)
select name, revenue
from facility_revenue
where revenue < 1000
order by revenue;