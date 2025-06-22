SELECT * FROM spotify_db.data;
use spotify_db;

----- exploratory data analysis ------
select count(*) as total_rows from spotify_db.data;

SELECT COUNT(*) as total_columns
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = 'data' AND table_schema = 'spotify_db';

select count(distinct artist) as unique_artist from spotify_db.data;

select distinct album_type from spotify_db.data;

select max(duration_min) as max_durtn, min(duration_min) as min_durtn from spotify_db.data;

select * from spotify_db.data
where duration_min = 0;

-- delete the songs data having suration_min zero --
set sql_safe_updates = 0;

delete from spotify_db.data where duration_min = 0;

select * from spotify_db.data where duration_min = 0;
select count(*) as total_rows from spotify_db.data;

select column_name from information_schema.columns
where table_schema = 'spotify_db' and table_name = 'data';  

select distinct channel from spotify_db.data;

select distinct most_playedon from spotify_db.data;

/*--------------------------------------------
--- Data analysis - Easy category 
--------------------------------------------*/
-- 1.Retrieve the names of all tracks that have more than 1 billion streams. --
SELECT * FROM spotify_db.data;

select * from spotify_db.data where stream > 1000000000;
select track from spotify_db.data where stream > 1000000000;

-- 2.List all albums along with their respective artists. --
select distinct album, artist from spotify_db.data;

-- 3.Get the total number of comments for tracks where licensed = TRUE --
SELECT * FROM spotify_db.data;

select sum(comments) as total_comments from spotify_db.data
where licensed = 'true';

-- 4.Find all tracks that belong to the album type single. --
SELECT * FROM spotify_db.data;

select track from spotify_db.data where album_type = 'single';
select count(track) as total_single_tracks from spotify_db.data where album_type = 'single';

-- 5.Count the total number of tracks by each artist. --
select distinct(artist) from spotify_db.data;
select distinct artist, count(track) as total_tracks from spotify_db.data
group by artist;

/*--------------------------------------------
--- Data analysis - Medium category 
--------------------------------------------*/
-- 1.Calculate the average danceability of tracks in each album. --
SELECT * FROM spotify_db.data;
select distinct album from spotify_db.data;

select avg(danceability) from spotify_db.data;

select album, avg(danceability) as avg_danceability from spotify_db.data
group by album order by 2 desc;

-- 2.Find the top 5 tracks with the highest energy values. --
SELECT * FROM spotify_db.data;

select track, max(energy) from spotify_db.data
group by track
order by 2 desc
limit 5;

-- 3.List all tracks along with their views and likes where official_video = TRUE. --
SELECT * FROM spotify_db.data;

select track, sum(views) as total_views, sum(likes) as total_likes from spotify_db.data
where official_video = 'true'
group by 1
order by 2 desc;

-- 4.For each album, calculate the total views of all associated tracks. --
SELECT * FROM spotify_db.data;

select album,track, sum(views) as total_views from spotify_db.data
group by 1,2
order by 3 desc;

-- 5.Retrieve the track names that have been streamed on Spotify more than YouTube. --
SELECT * FROM spotify_db.data;

select * from 
(select track, 
     coalesce(sum(case when most_playedon = 'Youtube' then stream end),0) as streamed_youtube,
     coalesce(sum(case when most_playedon = 'spotify' then stream end),0) as streamed_spotify
from spotify_db.data
group by track) as t1
where streamed_spotify > streamed_youtube
      and
	  streamed_youtube <> 0;
      
/*--------------------------------------------
--- Data analysis - Advance category 
--------------------------------------------*/
-- 1.Find the top 3 most-viewed tracks for each artist using window functions. --
SELECT * FROM spotify_db.data;

select artist, track, sum(views) as total_views
from spotify_db.data
group by 1,2
order by 1,3 desc;

with ranking_artist as
(select artist, track, sum(views) as total_views,
     dense_rank() over(partition by artist order by sum(views) desc) as rnk
from spotify_db.data
group by 1,2
order by 1,3 desc)
select * from ranking_artist
where  rnk <= 3;

-- 2.Write a query to find tracks where the liveness score is above the average. --
SELECT * FROM spotify_db.data;

select avg(liveness) as avg_liveness from spotify_db.data;

select track, artist, liveness
from spotify_db.data
where liveness > (select avg(liveness) as avg_liveness from spotify_db.data);
      
-- 3.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album. --
SELECT * FROM spotify_db.data;

with cte as
(select album,
       max(energy) as highest_energy, 
       min(energy) as lowest_energy
from spotify_db.data
group by album)
select album,
       (highest_energy - lowest_energy) as difference_in_energy
from cte
order by difference_in_energy desc;       

-- 4.Find tracks where the energy-to-liveness ratio is greater than 1.2 --
SELECT * FROM spotify_db.data;

with  cte as
(select track, energy, liveness,
       (case when liveness = 0 then 0 else (energy/liveness) end) as eng_to_liveness_ratio
from spotify_db.data)
select track, avg(eng_to_liveness_ratio) as averg_eng_to_liveness_ratio  
from cte
group by track
having avg(eng_to_liveness_ratio) > 1.2
order by averg_eng_to_liveness_ratio desc;

-- 5.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions. --
SELECT * FROM spotify_db.data;

select track,
       likes,
       views,
       sum(likes) over(order by views) as cumulative_likes
from spotify_db.data
order by 3 desc;       

/*--------------------------------------------
------------- End of project -----------------
--------------------------------------------*/
      