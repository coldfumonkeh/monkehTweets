component {
	function run () {
		describe("Dummy test", function () {
			it("runs a test", function () {
				expect(true).toBeTrue();
			});
			/* this is a known failing test
			it("fails", function () {
				expect(false).toBeTrue();
			});
			*/
		});
	}
}