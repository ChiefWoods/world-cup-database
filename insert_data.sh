#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

function insert_team {
  TEAM=$($PSQL "SELECT name FROM teams WHERE name = '$1'")

  if [[ -z $TEAM ]]
  then
    $PSQL "INSERT INTO teams (name) VALUES ('$1')"
  fi
}

function insert_game {
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$3'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$4'")

  $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($1, '$2', '$WINNER_ID', '$OPPONENT_ID', $5, $6)"
}

echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    insert_team "$WINNER"
  fi

  if [[ $OPPONENT != "opponent" ]]
  then
    insert_team "$OPPONENT"
  fi

  if [[ $WINNER != "winner" ]]
  then
    insert_game $YEAR "$ROUND" "$WINNER" "$OPPONENT" $WINNER_GOALS $OPPONENT_GOALS
  fi
done
