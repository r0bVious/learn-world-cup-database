#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#clear tables and restart id sequencing for testing
TRUNC_TABLE_RESULT=$($PSQL "TRUNCATE teams, games;")
if [[ $TRUNC_TABLE_RESULT == "TRUNCATE TABLE" ]]
then
  $PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1;"
  $PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;"
  echo -e '\n~~ Tables cleared! ~~\n'
fi

echo "Running insert scripts..."
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then

    ##ADD TEAMS SECTION
    #get team_id for winner
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

    #if doesn't exist, then insert
    if [[ -z $WINNER_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER');")
      if [[ $INSERT_TEAM_RESULT == "Insert 0 1" ]]
      then
        echo "New team added to teams: '$WINNER'"
      fi

      #get newly created team_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi

    #get team_id for opponent
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    #if doesn't exist, then insert
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT');")
      if [[ $INSERT_TEAM_RESULT == "Insert 0 1" ]]
      then
        echo "New team added to teams: '$OPPONENT'"
      fi

      #get newly created team_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi

    #INSERT GAMES SECTION
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")

  fi
done