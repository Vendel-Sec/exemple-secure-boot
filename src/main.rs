use esp_idf_hal::gpio::PinDriver;
use esp_idf_hal::peripherals::Peripherals;
use esp_idf_hal::delay::Delay;
use esp_idf_svc::log::EspLogger;

fn main() {
    // TODO: changer la frequence de clignotement ici
    const BLINKY_FREQUENCY_HZ: f32 = 1.0;

    // Initialiser le systeme ESP-IDF et le logger
    esp_idf_svc::sys::link_patches();
    EspLogger::initialize_default();

    log::info!("Lancement du programme utilisateur");

    // Obtenir les peripheriques
    let peripherals = Peripherals::take().unwrap();

    // Configurer le GPIO
    let mut led = PinDriver::output(peripherals.pins.gpio2).unwrap();

    // Configurer les valeurs de delai
    let delay = Delay::new_default();
    let delay_value  = (1_000_000.0 / BLINKY_FREQUENCY_HZ / 2.0) as u32;

    log::info!("Demarrage de la boucle principale");

    // Boucle principale
    loop {
        led.set_high().unwrap();
        delay.delay_us(delay_value);

        led.set_low().unwrap();
        delay.delay_us(delay_value);
    }
}
