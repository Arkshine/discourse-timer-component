import { apiInitializer } from "discourse/lib/api";
import Timer from "../components/timer";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet(settings.outlet_location, Timer);
});
