-- 1 create sp_get_country_starts_with (text) --> return table with all countries starting with the parameter
-- 2 create sp_get_movies_short_long (bool) --> return table of movies join country if bool = true -> timestamp false release_date::date

create or replace FUNCTION sp_get_movies_starts(starter text)
returns TABLE(id bigint, title text, release_date timestamp, country_id bigint, price double precision)
language plpgsql
    AS
    $$
    BEGIN
        -- update
        -- inert
        return query
        SELECT movies.id, movies.title, movies.release_date, movies.country_id, movies.price
               FROM movies
            WHERE movies.title like concat(starter,'%');
    end;
    $$;

select * from sp_get_movies_starts('b');
