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
    $$

select * from sp_get_movies_over(80)
