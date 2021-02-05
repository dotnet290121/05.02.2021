create or replace FUNCTION sp_get_movies_over(_min_price double precision )
returns TABLE(id bigint, title text, release_date timestamp, price double precision, country_id bigint)
language plpgsql
    AS
    $$
    BEGIN
        -- update
        -- inert
        return query
        SELECT * FROM movies WHERE movies.price > _min_price;
    end;
    $$;

select * from sp_get_movies_over(80);

create or replace FUNCTION sp_get_movies_data(discount boolean)
returns TABLE(id bigint, title text, release_date timestamp, country_id bigint, price double precision)
language plpgsql
    AS
    $$
    BEGIN
        -- update
        -- inert
        return query
        SELECT movies.id, movies.title, movies.release_date, movies.country_id,
               CASE WHEN discount = True THEN movies.price / 2.0 ELSE movies.price END
               FROM movies ;
    end;
    $$;

select * from sp_get_movies_data(TRUE);
select * from sp_get_movies_data(FALSE);


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

select * from movies;

--drop procedure sp_insert_new_movies;
create or replace function sp_insert_new_movies(_title text, _release_date timestamp, _country_id bigint, _price double precision) returns bigint
language plpgsql
    AS
    $$
    DECLARE
        new_id bigint;
    BEGIN
        INSERT INTO movies(title, release_date, price, country_id) values (_title, _release_date, _price, _country_id)
        returning id into new_id;
        return new_id;
    end;
    $$;

select * from sp_insert_new_movies('Greek wedding', '2010-01-19', 1, 70.1);

CREATE OR REPLACE FUNCTION a_sp_get_movies_in_middle()
returns TABLE(id bigint, title text, release_date timestamp, price double precision, country_id bigint, c_id bigint, country_name text) AS
    $$
    DECLARE
        --cheapest_movie_id bigint;
        --expensive_movie_id bigint;
    BEGIN
        RETURN QUERY
            -- with field 1 ...
            WITH cheapest_movie_id AS
                (
                    select * from movies
                    where movies.price = (select (min(movies.price)) from movies)
                    limit 1
                ),
            -- with field 2 ...
            expensive_movie_id AS
                (
                    select * from movies
                    where movies.price = (select (max(movies.price)) from movies)
                    limit 1
                )
            -- query 1
                 select * from movies m
                join country c on m.country_id = c.id
                where m.id != (select cheapest_movie_id.id from cheapest_movie_id) AND m.id != (select expensive_movie_id.id from expensive_movie_id);
    END;
$$ LANGUAGE plpgsql;

select * from a_sp_get_movies_in_middle();
                                          
                                          

CREATE OR REPLACE FUNCTION sp_generate_rnd(_max integer) -- 1-max
returns integer AS

$$
    BEGIN
            return (random() * (_max-1) + 1);
end;
    $$ language plpgsql;

select * from random();

select * from sp_generate_rnd(40);

CREATE OR REPLACE FUNCTION sp_sum_movies() 
returns integer AS

$$
    declare
        sum double precision := 0;
        movie_price double precision := 0.0;
    BEGIN
        FOR i IN 1..(select max(id) from movies)
        loop
            select movies.price into movie_price from movies where movies.id = i;
            if found then
                sum := sum + movie_price;
            end if;
        end loop;
        return sum;
    end;
    $$ language plpgsql;

select * from sp_sum_movies();
                                          
                                          -- use PERFORM instead of SELECT for procedures (select inly possible in functions) !!!!


-- upsert: try to insert, if exists them update only
create or replace function sp_upsert_new_movies(_title text, _release_date timestamp, _country_id bigint, _price double precision) returns bigint
language plpgsql
    AS
    $$
    DECLARE
        record_id bigint;
    BEGIN
        SELECT movies.id into record_id from movies
            where movies.title = _title;
        if not found THEN
            INSERT INTO movies(title, release_date, price, country_id) values (_title, _release_date, _price, _country_id)
            returning id into record_id;
        ELSE
            update movies
                set release_date = _release_date, country_id = _country_id, price = _price
            where movies.id = record_id;
        end if;
        return record_id;
    end;
    $$;

select * from sp_upsert_new_movies('Greek wedding', '2010-01-19', 1, 85.1);
select * from sp_upsert_new_movies('Mandalorien', '2019-03-20', 2, 37.3);
select * from movies;

CREATE OR REPLACE FUNCTION sp_div(x integer, y integer) returns double precision
language plpgsql AS
    $$
        DECLARE
            result double precision := 0;
        BEGIN
            if y > 0 THEN
                RAISE division_by_zero ;
            end if;
            return result;
            EXCEPTION
                when division_by_zero THEN
                    RAISE NOTICE 'caught division by zero';
                    return null;
                when OTHERS THEN
                    -- all other types of exceptions
                    RAISE NOTICE 'caught other';
                    return null;
        end;
    $$;

select * from sp_div(1, 100);

create table grades
(
	id bigserial
		constraint grades_pk
			primary key,
	class_id bigint not null,
	student_id bigint not null,
	grade double precision default 0 not null
);

select count(*), class_id from grades
group by class_id;

select *,
       row_number() over (partition by student_id) row_num
       from grades;

select *, grade - avg(grade) over (partition by class_id) diff_from_class_avg , avg(grade) over (partition by class_id)  class_avg
       from grades;

select *, price - avg(price) over (partition by country_id) diff
       from movies
    order by country_id;

