 	Feature: Dispatcher
	
	In order to use the web application
	As a dispatcher
	I want to singup in the database

	Scenario: I will redirct to Dispatcher registration page
		Given a user visits the root page
    And I see two button on page
    When I click on Register as dispatcher
    And It will redirect to new dispatcher registration page