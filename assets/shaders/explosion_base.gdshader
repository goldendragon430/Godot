shader_type particles;

float rand_from_seed(in uint seed) {
  int k;
  int s = int(seed);
  if (s == 0)
    s = 305420679;
  k = s / 127773;
  s = 16807 * (s - k * 127773) - 2836 * k;
  if (s < 0)
    s += 2147483647;
  seed = uint(s);
  return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = (x >> uint(16)) ^ x;
  return x;
}

void start() {
	uint alt_seed1 = hash(NUMBER + uint(1) + RANDOM_SEED);
	uint alt_seed2 = hash(NUMBER + uint(27) + RANDOM_SEED);
	uint alt_seed3 = hash(NUMBER + uint(43) + RANDOM_SEED);
	uint alt_seed4 = hash(NUMBER + uint(111) + RANDOM_SEED);
	
	CUSTOM.x = rand_from_seed(alt_seed1);
	vec3 position = vec3(rand_from_seed(alt_seed2) * 5.0 - 2.0,
                     rand_from_seed(alt_seed3) * 5.0 - 2.0,
                     rand_from_seed(alt_seed4) * 5.0 - 2.0);
	TRANSFORM[3].xyz = position * 5.0;
	VELOCITY.z = cos(TIME + CUSTOM.x * 6.28) * 4.0 + 6.0;
}

void process() {
	// Place process code here.
}
