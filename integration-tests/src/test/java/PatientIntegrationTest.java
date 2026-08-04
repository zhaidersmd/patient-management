import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.notNullValue;

public class PatientIntegrationTest {

    @BeforeAll
    public static void setUp() {
        RestAssured.baseURI = "http://localhost:4004";
        RestAssured.defaultParser = io.restassured.parsing.Parser.JSON;
    }
    @Test
    public void shouldReturnPatientsWithValidToken() {
        String payload = """
                { "email" : "testuser@test.com", "password" : "password123" }
        """;

        String token = given()
                .contentType("application/json")
                .body(payload)
                .when()
                .post("/auth/login")
                .then()
                .statusCode(200)
                .extract()
                .jsonPath()
                .getString("token");

        Response loginResponse = given() .contentType("application/json")
                .body(payload)
                .when()
                .post("/auth/login");

        loginResponse.prettyPrint();

        String token2 = loginResponse.jsonPath().getString("token");
        System.out.println("TOKEN = " + token2);


        given()
                .header("Authorization", "Bearer " + token)
                .accept("application/json")
                .when()
                .get("/api/patients")
                .then()
                .statusCode(200)
                .body("size()", greaterThan(0));


    }
}
