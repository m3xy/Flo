float distance = 0, maxDistance = 0;
float kills = -nEnemies;
float shots = nEnemies;
float hits = nEnemies;

int score() {
  //return round(((distance) + ((kills * 2) - (shots * 0.05))) * player.hp);
  return max(0, round(((distance + (kills*10*(hits/shots))) * (player.hp/player.maxHP))));
}

int maxScore() {
  return max(1, round(maxDistance + (kills*10)));
}
