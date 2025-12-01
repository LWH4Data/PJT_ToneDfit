package com.example.tone_d_fit_dev;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;

@SpringBootApplication
public class ToneDFitDevApplication {

	public static void main(String[] args) {
		SpringApplication.run(ToneDFitDevApplication.class, args);
	}

}
