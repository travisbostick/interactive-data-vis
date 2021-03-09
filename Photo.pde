class Photo {

	float day, hour, photoNum, x, y;
	String name;
	PImage image;

	Photo(String name, float day, float hour, float photoNum, float baseX, float baseY) {
		this.day = day;
		this.hour = hour;
		this.photoNum = photoNum;
		y = baseY - 4*photoNum;
		x = baseX + 130*(day - 17);
		this.name = name;
	}


}
