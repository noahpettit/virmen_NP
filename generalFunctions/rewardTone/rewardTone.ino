
// notes to play, corresponding to the 3 sensors:

int input = 0;
float sec = 0;
unsigned long ms = 0;

void setup() {
Serial.begin(9600);
}

void loop() {
  
if (Serial.available() > 0) {
  input = Serial.read();
  sec = (float) input / 255;
  ms = sec * 1000;
  ms = (unsigned long) ms;
  tone(10, 10000, ms);
}

}
