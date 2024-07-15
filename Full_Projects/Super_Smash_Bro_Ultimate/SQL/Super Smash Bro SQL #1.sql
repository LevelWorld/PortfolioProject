# Author: Leul Wolde
#
# purpose:
# 			* To show competency in sql in MYSQL to 
#         		ulimately be a data analysis.
# 			* To show how different characters and their 
#           	respective moves and attributes in
# 				the video game 'Super Smash Bro Ulimate' 
#				compare to each other.
# Please Note: 
# 			This might be obvious, but to aid assessing my skill and save time for
# 			potenital employers I would like to communicate the follow:
# 
#			*Each block of code will communicate what the goal of the block was.
#			*The further down the script the more complicated the query becomes.
#			*The tables where derived from scraping the website 'ultimateframedata.com'
#				using Python
#			*This is a completely original project, visualizations, data, examples of other skills
#				and other projects are avaliable on the my github 
# 				'https://github.com/LevelWorld/PortfolioProject'

# Some of the most common used moves are those found in ground_attack table
# Let find the strongest Ground Attack
select `Character`, movename, basedamage
from ssb.ground_attacks
order by basedamage desc;

######################################################################################
# A lot of characters have the same basic moves (i.e. up air, Forward air, etc.)
# Let find how charcter have a paticular move in the aerial_attacks table
select movename, count(movename) as count_of_moves
from ssb.aerial_attacks
group by movename
order by count_of_moves desc;

######################################################################################
# that was great but a lot of moves had very similar names 
# but were counted as different moves
# i.e. Forward air , Forward air 1 Forward air 2, Froward air 3
select * 
from ssb.aerial_attacks
order by movename;

# I personally don't like deleting data, so I will create a column to 
# do all editing on.
alter table ssb.aerial_attacks
add column move_name varchar(255);

# This block will remove any numbers from a the end text 
# then add them to new column
update ssb.aerial_attacks 
set move_name = left(movename, length(movename) - 2)
where movename REGEXP '[0-9]';

# This block will copy all data that was skipped in block above
update ssb.aerial_attacks 
set move_name = movename
where movename not REGEXP '[0-9]';

# This is the result
select move_name, count(move_name) as count_of_moves
from ssb.aerial_attacks
group by move_name
having (count_of_moves > 1)
order by count_of_moves desc;

######################################################################################

# unfornately a lot of columns are strings with 
# either a (leading and/or trailing) space or are key words. So I want to rename them 
SELECT *
FROM ssb_non_offensives.air_speed ;
#'Zero Suit Samus'  does not have a leading space
SELECT *
FROM ssb_non_offensives.weight;
#' Zero Suit Samus'   does have a leading space

# look like some rows in weight table has some extra whitespace
# causing no row to be return when joining these two tables
# this will fix that.
Update ssb_non_offensives.weight
Set `character` = trim(`character`);

# Show casing a a join
SELECT w.Character, w.Rank as 'Weight_Rank',  w.Weight, air.`Air speed`, air.Rank as 'Air_speed_rank'
FROM ssb_non_offensives.weight as w
LEFT JOIN ssb_non_offensives.air_speed  as air
	on w.`Character` = air.`Character`
;
##########################################################################################################
# Remember that first block about finding the strongest ground attack
# I want to rank character by their strongest attack, then join it to the a table from the previous block
#
# Here is where I will use CTE
with max_ground_attack as (
	Select
    `Character`,
    max(basedamage) as max_base_damage
    from ssb.ground_attack
    group by `Character`
)

select distinct `Character`,  max(basedamage) as max_base_damage, 
	row_number() over (order by max_base_damage desc) as Ground_attack_rank
from max_ground_attack
group by `Character`;

WITH max_damage_per_character AS (
    SELECT 
        `Character`,
        MAX(basedamage) AS max_base_damage
    FROM 
        ssb.ground_attacks
    GROUP BY 
        `Character`
)
SELECT 
    `Character`,
    max_base_damage,
    ROW_NUMBER() OVER (ORDER BY max_base_damage DESC) AS Ground_attack_rank
FROM 
    max_damage_per_character;
### 
# I figure it would be easier just to create a new table and only have the data I'm
# interested in and join on said table
CREATE TABLE ssb.rank_by_ground_attack (
    Rank_By_Strongest INT,
    Character_name VARCHAR(255) CHARACTER SET UTF8MB4,
    Move_name VARCHAR(255) CHARACTER SET UTF8MB4,
    Base_damage FLOAT
);

INSERT INTO ssb.rank_by_ground_attack (
	Rank_By_Strongest, 
    Character_name, 
    Move_name, 
    Base_damage
)
WITH max_damage_per_character AS (
    SELECT 
        `Character`,
        MAX(basedamage) AS max_base_damage,
        MAX(move_name) AS move_name  
    FROM 
        ssb.ground_attacks
    GROUP BY 
        `Character`
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY max_base_damage DESC) AS Ground_attack_rank,
    `Character` AS Character_name,
    move_name AS Move_name,
    max_base_damage AS Base_damage
FROM 
    max_damage_per_character;
    
#### Thes results are below
select * 
from ssb.rank_by_ground_attack  as Rank_g_a
join ssb_non_offensives.weight  as w
	on Rank_g_a.Character_name = w.`Character`;
