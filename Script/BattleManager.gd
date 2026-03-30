extends Node

enum CardType {ROCK,PAPER,SCISSORS}

func rps_result(a: int, b: int) -> int:
	if (a == CardType.ROCK and b == CardType.SCISSORS) \
	or (a == CardType.PAPER and b == CardType.ROCK) \
	or (a == CardType.SCISSORS and b == CardType.PAPER):
		return 1
	return 0
