private import std.stdio;
private import std.string;
private import std.conv;
private import std.datetime;
private import std.string;

int count = 0;
int size = 1;
bool showDetail = false;

class Direction {
	static Direction Upper;
	static Direction Under;
	static Direction Left;
	static Direction Right;
	static Direction All[4];

	private Position delegate(Position) _from;

	static this() {
		Position delegate(Position) delegate(int delegate(int), int delegate(int)) nextIfIn = (fx, fy) {
			return (p) {
				int nx = fx(p.x);
				int ny = fy(p.y);
				if (nx >= 0 && ny >= 0
					&& nx <= size && ny <= size) {
					return new Position(nx, ny);
				} else {
					return null;
				}
			};
		};

		Upper = new Direction(nextIfIn((x){ return x; }, (y){ return y-1; }));
		Under = new Direction(nextIfIn((x){ return x; }, (y){ return y+1; }));
		Left = new Direction(nextIfIn((x){ return x-1; }, (y){ return y; }));
		Right = new Direction(nextIfIn((x){ return x+1; }, (y){ return y; }));
		All = [Upper, Under, Left, Right];
	}
	private this(Position delegate(Position) arg) {
		this._from = arg;
	}
	Position from(Position p) {
		return _from(p);
	}
	static Direction reverse(Direction d) {
		if (d == Upper) return Under;
		if (d == Under) return Upper;
		if (d == Left) return Right;
		if (d == Right) return Left;
		writeln("??");
		throw new Exception("test");
		return null;
	}
}

class Position {
	immutable int x;
	immutable int y;

	this(int x, int y) {
		this.x = x;
		this.y = y;
	}
	bool isGoal() {
		return x == size
			&& y == size;
	}

	override bool opEquals(Object o) {
		Position p = cast(Position)o;
		if (p) {
			return p.x == this.x
				&& p.y == this.y;
		}
		return false;
	}

	override hash_t toHash() { return x * 17 + y + 5; }

	override int opCmp(Object o) {
		Position p = cast(Position)o;
		if (!p)
			return -1;
		if (x == p.x)
			return y - p.y;
		return x - p.x;
	}
	override string toString() {
		return format("(%d, %d)", x, y);
	}
}

void seek() {
	Position[] track;

	void show(Position[] list) {
		count ++;
		if (showDetail) {
			writeln(list);
		}
	}
	void seekIn(Position current) {
		if (current is null) return;
		if (contains(track, current)) return;
		if (current.isGoal()) {
			show(track);
			return;
		}

		track ~= current;
		foreach (Direction d; Direction.All) {
			seekIn(d.from(current));
		}
		track = track[0..track.length - 1];
	}

	seekIn(new Position(0,0));
}

bool contains(Position[] list, Position p) {
	for (int i = 0; i < list.length; i ++) {
		if (list[i] == p) return true;
	}
	return false;
}

void main(string[] args) {
	for (int i = 1; i < args.length; i ++) {
		if (args[i] == "-s") {
			showDetail = true;
		}
		if (args[i].isNumeric()) {
			size = to!(int)(args[i]);
		}
	}
	auto starttime = Clock.currTime();
	seek();
	writeln(count);

	auto elapsedtime = Clock.currTime() - starttime;
	writeln(elapsedtime);
}
