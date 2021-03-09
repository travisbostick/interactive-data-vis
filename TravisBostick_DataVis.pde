import java.util.*;

ArrayList<Table> tables = new ArrayList<Table>();

Photo[][] allPhotos;

int[] isIt;

float baseX;
float baseY;

boolean justOne;
int theOne;

String[] dayStrings = {"9/10", "9/11", "9/12", "9/13", "9/14", "9/15", "9/16",
	"9/17", "9/18", "9/19", "9/20", "9/21", "9/22", "9/23", "9/24", "9/25",
	"9/26"};

boolean inNight;
boolean lateNights;

void setup() {
	// size(1920, 1080);
	fullScreen();

	inNight = false;
	lateNights = false;

	baseY = height * 0.9;
	baseX = width / 15;

	String[] tableNames = getTableNames();

	allPhotos = new Photo[tableNames.length][];

	for (int i = 0; i < tableNames.length; i++) {
		tables.add(loadTable(tableNames[i], "header"));


		int numOfPhotos = tables.get(i).getRowCount();

		if (tableNames[i] == "My_Hats.csv") {
			numOfPhotos -= 12;
		}

		Photo[] photos = new Photo[numOfPhotos];

		String[] names = new String[numOfPhotos];

		Integer[][] daysHours = new Integer[numOfPhotos][3];

		int rowCount = 0;
		int l = 0;
		while (rowCount < tables.get(i).getRowCount()) {
			TableRow row = tables.get(i).getRow(rowCount);
			String[] times = row.getString(1).split("_|\\)|__|\\?");
			if (times.length >= 3) {
				if (times[2].equals("")) {
					times[2] = times[3];
					times[3] = times[4];
				}
				if (times[3].equals("12am")) {
					times[3] = "00";
				}
				names[l] = row.getString(0);
				daysHours[l][0] = Integer.parseInt(times[2]);
				daysHours[l][1] = Integer.parseInt(times[3]);
				daysHours[l][2] = l;
				l++;
			} else {
				rowCount++;
			}
			rowCount++;
		}

		Arrays.sort(daysHours, new Comparator<Integer[]>() {
			@Override
			public int compare(Integer[] o1, Integer[] o2) {
				Integer day1 = o1[0];
				Integer day2 = o2[0];
				return day1.compareTo(day2);
			}
		});

		Map<Integer, Integer> dupes = new HashMap<Integer, Integer>();
		for (int j = 0; j < daysHours.length; j++) {
			if (dupes.containsKey(daysHours[j][0])) {
				dupes.put(daysHours[j][0], (int) dupes.get(daysHours[j][0]) + 1);
			} else {
				dupes.put(daysHours[j][0], 1);
			}
		}


		Set daySet = dupes.keySet();
		Object dayArr[] = new Object[(int) daySet.size()];
		dayArr = daySet.toArray();
		Arrays.sort(dayArr);

		int index = 0;
		int newDaysHours[][] = new int[numOfPhotos][3];
		for (int j = 0; j < dayArr.length; j++) {
			Integer hoursNames[][] = new Integer[dupes.get(dayArr[j])][2];
			int hourInd = 0;
			for (int k = index; k < index + dupes.get(dayArr[j]); k++) {
				hoursNames[hourInd][0] = daysHours[k][1];
				hoursNames[hourInd][1] = daysHours[k][2];
				// hours[hourInd] = daysHours[k][1];
				hourInd++;
			}
			Arrays.sort(hoursNames, new Comparator<Integer[]>() {
				@Override
				public int compare(Integer[] o1, Integer[] o2) {
					Integer hour1 = o1[0];
					Integer hour2 = o2[0];
					return hour1.compareTo(hour2);
				}
			});
			for (int k = 0; k < hoursNames.length; k++) {
				newDaysHours[index][0] = (int) dayArr[j];
				newDaysHours[index][1] = hoursNames[k][0];
				newDaysHours[index][2] = hoursNames[k][1];
				index++;
			}
		}

		for (int j = 0; j < daysHours.length; j++) {
			photos[j] = new Photo(names[newDaysHours[j][2]], newDaysHours[j][0], newDaysHours[j][1], j, baseX, baseY);
		}
		
		allPhotos[i] = photos;

		isIt = new int[allPhotos.length];

	}

}

void draw() {
	background(0);

	stroke(0, 0, 255);
	fill(0, 0, 255);
	if ((mouseX >= width/3) && (mouseX <= width/3 + 50)
		&& (mouseY >= height/12) && (mouseY <= height/12 + 50)) {
		stroke(40, 40, 255);
		fill(40, 40, 255);
		inNight = true;
	} else {
		inNight = false;
	}
	rect(width/3, height/12, 50, 50);
	stroke(255);
	textSize(30);
	text("Night Time (10pm - 3am)", width/3 + 50 + 10, height/12+35);

	stroke(255);
	fill(255);
	for (int i = 0; i < dayStrings.length; i++) {
		textSize(12);
		text(dayStrings[i], baseX + (width/18)*i - 12, baseY + height / 50);
		line(baseX + (width/18)*i, baseY, baseX + (width/18)*i, baseY + height/200);
	}
	// stroke(255);
	// line(baseX, baseY, width - baseX/2, baseY);
	for (int i = 0; i < allPhotos.length; i++) {
		stroke(255);
		strokeWeight(1);
		if (justOne) {
			textSize(50);
			String[] titles = allPhotos[theOne][0].name.split("_|001|000|00|01|.jpg|.jpeg|.JPG");
			String title = titles[0];
			if (titles.length > 1) {
				title += "_" + titles[1];
			}
			text(title, width / 25, height / 8);
			strokeWeight(2);
			if (i != theOne) {
				stroke(80);
				strokeWeight(1);
			}
		}
		float oldX = baseX;
		float oldY = baseY;
		int inHere = 0;
		for (int j = 0; j < allPhotos[i].length; j++) {
			Photo photo = allPhotos[i][j];
			float y = baseY - (height/174) * photo.photoNum;
			float x = baseX + (width/18)*(photo.day - 10) + photo.hour*((width/18)/24);
			if (j == 0) {
				oldX = x;
				oldY = baseY;
			}
			if (lateNights) {
				if ((photo.hour >= 22) || (photo.hour <= 3)) {
					stroke(0, 0, 255);
				} else {
					if (justOne) {
						if (i == theOne) {
							stroke(255);
						} else {
							stroke(80);
						}
					} else {
						stroke(200);
					}
				}
			}
			line(oldX, oldY, x, y);
			if ((mouseX >= (x-3)) && (mouseX <= (x+3))
				&& (mouseY >= (y-3)) && (mouseY <= (y+3))) {
				if (!justOne || i == theOne) {
					ellipse(x, y, 20, 20);
					textSize(12);
					text(photo.name, baseX, baseY + height / 20);
					try {
						PImage image = loadImage(photo.name.split(".jpeg|.jpg|.JPG")[0] + ".jpg");
						image(image,x-400, y-400,400,400);
					} catch (NullPointerException e) {
					}
				}
				inHere = 1;
			} else {
			}
			oldX = x;
			oldY = y;
		}
		isIt[i] = inHere;
	}
	stroke(255);
	line(baseX, baseY, width - baseX/2, baseY);
	line(baseX, baseY, baseX, baseY - ((height/174) * 120));
	int num = 0;
	textSize(12);
	for (int i = 0; i < 13; i++) {
		text(num, baseX - 30, baseY - ((height/174) * i * 10) + 5);
		line(baseX, baseY - ((height/174)*i*10), baseX-5, baseY - ((height/174)*i*10));
		num += 10;
	}
	textSize(15);
	text("Interactions Accumulated", 10, baseY - ((height/174)*124));
	text("Date", width/2 - 30, baseY + height / 20);
}

void mouseClicked() {
	if (justOne) {
		if ((mouseX >= width/3) && (mouseX <= width/3 + 50)
			&& (mouseY >= height/12) && (mouseY <= height/12 + 50)) {
		} else {
			if (isIt[theOne] == 0) {
				justOne = false;
			}
		}
	}
	for (int i = 0; i < isIt.length; i++) {
		if (isIt[i] == 1) {
			justOne = true;
			theOne = i;
		}
	}
	if (inNight) {
		lateNights = !lateNights;
	}
}

String[] getTableNames() {
	return new String[]{
		"black_notebook.csv",
		"blue_notebook.csv",
		"brown_curved.csv",
		"chair.csv",
		"climb_stairs.csv",
		"cross_button.csv",
		"drinking.csv",
		"every_sips.csv",
		"fancy_plants.csv",
		"file_explorer.csv",
		"game_event.csv",
		"Grey_Blanket.csv",
		"head_phones.csv",
		"headphones.csv",
		"ipad_drawing.csv",
		"lamp.csv",
		"LightSwitch.csv",
		"music_image.csv",
		"my_backpack.csv",
		"My_Hats.csv",
		"My_Shoes.csv",
		"notebook.csv",
		"pink_glasses.csv",
		"Pretty_Ink.csv",
		"sav_tunes.csv",
		"unlock_screen.csv",
		"walking_shoes.csv",
		"watch.csv",
		"window_pane.csv"};
}

// Naughty List:
// - 3d_pics.csv - 12 hour time
// - commuting_life.csv - 12 Hour time
// - flower_wallet.csv - 12 hour time
// - ipad.csv - No Hours
// - ipad_pro.csv - Incomplete
// - laptop_keyboard.csv - 12 Hour time, backwards
// - music_player.csv - 12 Hour time
// - my_bicycle.csv - 12 Hour time
// - picyPics.csv - Question Marks
// - planner_updates.csv - 12 Hour time
// - school_planner.csv - 12 Hour time
// - Thought_Language.csv - No Hours
// - twitter_shenanigans.csv - 12 Hour time
// - water_bottle4.csv - 12 Hour time
// - water_bottle7.csv - 12 Hour tim
// - white_board.csv - 12 Hour time

// Same-Named Water-Bottles
// "water_bottle.csv",
// "water_bottle2.csv",
// "water_bottle5.csv",
// "water_bottle6.csv",
// "water_bottle8.csv",
