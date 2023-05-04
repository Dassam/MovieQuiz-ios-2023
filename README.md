## **MovieQuiz**

MovieQuiz is an application with quizzes about movies from the top 250 rating and the most popular movies according to IMDb.


## **Ссылки**

[Layout in Figma](https://www.figma.com/file/l0IMG3Eys35fUrbvArtwsR/YP-Quiz?node-id=34%3A243)

[API IMDb](https://imdb-api.com/api#Top250Movies-header)

[Fonts](https://code.s3.yandex.net/Mobile/iOS/Fonts/MovieQuizFonts.zip)

## **Application Description**

- A one-page application with quizzes about movies from the top 250 rating and the most popular movies on IMDb. The user of the application answers questions about the rating of the movie in a sequential manner. At the end of each round of the game, statistics are displayed showing the number of correct answers and the user's best results. The goal of the game is to correctly answer all 10 questions in the round.

## **Functional Requirements**

- When the application is launched, a splash screen is displayed;
- After launching the application, a question screen is displayed with the question text, picture, and two answer options, "Yes" and "No," only one of which is correct;
- The quiz question is based on the IMDb rating of the movie on a 10-point scale, for example: "Is the rating of this movie higher than 6?";
- The user can click on one of the answer options to the question and receive feedback on whether it is correct or not, with the photo frame changing color accordingly;
- After selecting an answer to the question, the next question automatically appears after 1 second;
- After completing a round of 10 questions, an alert appears with the user's statistics and the option to play again;
- The statistics include: the current round result (the number of correct answers out of 10 questions), the number of played quizzes, the record (the best round result for the session, the date and time of that round), and the statistics of played quizzes in a percentage ratio (the average accuracy);
- The user can start a new round by clicking the "Play Again" button in the alert;
- If it is not possible to load the data, the user sees an alert with a message that something went wrong, as well as a button to repeat the network request.

______________________________________

## **Technical Requirement**
- The application must support iPhone devices with iOS 13, only portrait mode is provided;
- Interface elements adapt to iPhone screen resolutions, starting with X - layout for SE and iPad is not provided;
- The screens correspond to the layout - the correct fonts of the right sizes are used, all the inscriptions are in the right place, the location of all elements, button sizes and indents are exactly the same as in the layout.
