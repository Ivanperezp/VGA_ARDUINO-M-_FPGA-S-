#include <SPI.h>

#define SS_PIN 10  // Define the Slave Select (SS) pin
#define WIDTH 640
#define HEIGHT 480
#define SQUARE_SIZE 32  // Size of each square in the chessboard

void setup() {
  // Initialize SPI as master
  SPI.begin();
  
  // Set SS pin as output and set it HIGH (deselect slave)
  pinMode(SS_PIN, OUTPUT);
  digitalWrite(SS_PIN, HIGH);
  
  // Configure SPI speed and mode
  SPI.beginTransaction(SPISettings(8000000, MSBFIRST, SPI_MODE0));

  // Select slave
  digitalWrite(SS_PIN, LOW);

  for (int i = 0; i < 1200; i++) {
    SPI.transfer(random());
  }

  // Deselect slave
  digitalWrite(SS_PIN, HIGH);
}

void loop() {
}
