#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../include/ns_string.h"
#include "script.h"

int init_script() {

	return index_html;
}

int pre_page_index_html(void) {
   return NS_USE_CONFIGURED_THINK_TIME;
}

int check_page_index_html(void) {

	return login;
}

int pre_page_login(void) {
   return NS_USE_CONFIGURED_THINK_TIME;
}

int check_page_login(void) {

	return reservation;
}

int pre_page_reservation(void) {
   return NS_USE_CONFIGURED_THINK_TIME;
}

int check_page_reservation(void) {

	return findflight;
}

int pre_page_findflight(void) {
   return NS_USE_CONFIGURED_THINK_TIME;
}

int check_page_findflight(void) {

	return findflight_2;
}

int pre_page_findflight_2(void) {
   return NS_USE_CONFIGURED_THINK_TIME;
}

int check_page_findflight_2(void) {

	return findflight_3;
}

int pre_page_findflight_3(void) {
   return NS_USE_CONFIGURED_THINK_TIME;
}

int check_page_findflight_3(void) {

	return welcome;
}

int pre_page_welcome(void) {
   return NS_USE_CONFIGURED_THINK_TIME;
}

int check_page_welcome(void) {

	return -1;
}

void exit_script() {
	return;
}
