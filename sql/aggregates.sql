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

-- Top 3 facilities by total revenue, with their rank.
-- Guests (memid 0) pay guestcost, members pay membercost, per slot.
-- The rank is computed in a CTE because a window function
-- can't be used in a WHERE of the same query.
with ranked as (
    select fc.name,
           rank() over (order by sum(case
                                         when bk.memid = 0 then bk.slots * fc.guestcost
                                         else bk.slots * fc.membercost
                                     end) desc) as rank
    from cd.bookings bk
    join cd.facilities fc on fc.facid = bk.facid
    group by fc.name
)
select name, rank
from ranked
where rank <= 3
order by rank, name;


-- Payback time: months until each facility earns back its initial cost.
-- Data covers 3 months, so monthly revenue = total / 3.
-- months = initialoutlay / (monthly revenue - monthly maintenance)
with facility_revenue as (
    select fc.facid,
           fc.name,
           fc.initialoutlay,
           fc.monthlymaintenance,
           sum(case
                   when bk.memid = 0 then bk.slots * fc.guestcost
                   else bk.slots * fc.membercost
               end) as revenue
    from cd.bookings bk
    join cd.facilities fc on fc.facid = bk.facid
    group by fc.facid, fc.name, fc.initialoutlay, fc.monthlymaintenance
)
select name,
       initialoutlay / (revenue / 3 - monthlymaintenance) as months
from facility_revenue
order by name;


-- Rolling 15-day average of daily revenue for each day in August 2012.
-- Days with no bookings count as 0.
-- Steps: revenue per day -> full calendar -> fill gaps with 0
--        -> average of each day and the 14 before it -> keep August.
with daily_revenue as (
    select bk.starttime::date as date,
           sum(bk.slots *
               case
                   when bk.memid = 0 then fc.guestcost
                   else fc.membercost
               end) as rev
    from cd.bookings bk
    join cd.facilities fc on fc.facid = bk.facid
    group by bk.starttime::date
),
calendar as (
    -- Starts 14 days before 1 August so the first August day has full history.
    select generate_series('2012-07-18'::date,
                           '2012-08-31'::date,
                           interval '1 day')::date as date
),
filled as (
    select c.date,
           coalesce(d.rev, 0) as rev
    from calendar c
    left join daily_revenue d on d.date = c.date
),
rolling as (
    select date,
           avg(rev) over (order by date
                          rows between 14 preceding and current row) as revenue
    from filled
)
select date, revenue
from rolling
where date >= '2012-08-01'
order by date;